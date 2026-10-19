#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const detectModule = require('./src/detect');
const driver = require('./src/driver');

const SUPPORTED_EXTENSIONS = ['.lua', '.luau'];

function parseArgs(argv) {
  const args = {
    inputs: [],
    output: null,
    detect: false,
    plugin: null,
    noDevirt: false,
    noHooks: false,
    noFold: false,
    debug: false,
    strings: false,
    keepHarness: false,
    keepPreamble: false,
    timeout: 90,
    budget: 30,
    maxRuns: 12,
    devirtRounds: 200,
    executor: 'Wave',
    inputText: null,
  };

  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--detect') { args.detect = true; }
    else if (a === '--plugin') { args.plugin = argv[++i]; }
    else if (a === '--no-devirt') { args.noDevirt = true; }
    else if (a === '--no-hooks') { args.noHooks = true; }
    else if (a === '--no-fold') { args.noFold = true; }
    else if (a === '--debug') { args.debug = true; }
    else if (a === '--strings') { args.strings = true; }
    else if (a === '--keep-harness') { args.keepHarness = true; }
    else if (a === '--keep-preamble') { args.keepPreamble = true; }
    else if (a === '-o' || a === '--output') { args.output = argv[++i]; }
    else if (a === '--timeout') { args.timeout = parseInt(argv[++i], 10); }
    else if (a === '--prelude-file') { args.preludeFile = argv[++i]; }
    else if (a === '--budget') { args.budget = parseInt(argv[++i], 10); }
    else if (a === '--max-runs') { args.maxRuns = parseInt(argv[++i], 10); }
    else if (a === '--devirt-rounds') { args.devirtRounds = parseInt(argv[++i], 10); }
    else if (a === '--executor') { args.executor = argv[++i]; }
    else if (a === '--input-text') { args.inputText = argv[++i]; }
    else if (a === '--cfg-json') {
      // extra harness CFG as inline JSON or '@file.json' (e.g. readfile_map,
      // http_map, real_json) -- merged into the cfg of every run
      let spec = argv[++i];
      if (spec.startsWith('@')) spec = fs.readFileSync(spec.slice(1), 'utf8');
      args.cfgJson = JSON.parse(spec);
    }
    else if (!a.startsWith('-')) { args.inputs.push(a); }
  }

  return args;
}

class Job {
  constructor(inputPath, source, args, tracePath, debug, obfuscator = '') {
    this.input = inputPath;
    this.source = source;
    this.sourcePath = inputPath;
    this.args = args;
    this.tracePath = tracePath;
    this.debug = debug;
    this.obfuscator = obfuscator;
  }

  creditHeader() {
    return '';
  }

  get base() {
    return this.tracePath.replace(/\.(deobf\.luau|luau)$/, '');
  }

  path(suffix) {
    return this.base + suffix;
  }

  wrote(p) {
    if (this.debug) process.stderr.write(`[+] wrote ${p}\n`);
  }

  write(p, text, encoding = 'utf8') {
    fs.writeFileSync(p, text, { encoding });
    this.wrote(p);
    return p;
  }

  get outdir() {
    return path.dirname(path.resolve(this.tracePath));
  }
}

function collectInputFiles(rawPaths) {
  const files = [];
  const seen = new Set();

  for (const raw of rawPaths) {
    const abs = path.resolve(raw);
    if (!fs.existsSync(abs)) {
      process.stderr.write(`[!] path not found, skipping: ${raw}\n`);
      continue;
    }
    const stat = fs.statSync(abs);
    if (stat.isDirectory()) {
      const entries = fs.readdirSync(abs, { withFileTypes: true });
      for (const entry of entries) {
        if (entry.isFile() && SUPPORTED_EXTENSIONS.includes(path.extname(entry.name).toLowerCase())) {
          const filePath = path.join(abs, entry.name);
          if (!seen.has(filePath)) {
            seen.add(filePath);
            files.push(filePath);
          }
        }
      }
    } else if (stat.isFile()) {
      const ext = path.extname(abs).toLowerCase();
      if (!SUPPORTED_EXTENSIONS.includes(ext)) {
        process.stderr.write(`[!] unsupported extension for ${raw} (expected ${SUPPORTED_EXTENSIONS.join(', ')})\n`);
        continue;
      }
      if (!seen.has(abs)) {
        seen.add(abs);
        files.push(abs);
      }
    }
  }

  return files;
}

async function processFile(absInput, args) {
  const source = fs.readFileSync(absInput, 'latin1');
  let plugin, confidence;
  if (args.plugin) {
    plugin = detectModule.byName(args.plugin); // force a plugin (e.g. v14.x headers score 0.3)
    confidence = 1.0;
  } else {
    ({ plugin, confidence } = detectModule.detect(source));
  }

  if (args.detect) {
    console.log(`${path.basename(absInput)}\t${plugin.name}\t${confidence.toFixed(2)}\t${plugin.label}`);
    return;
  }

  process.stderr.write(`[*] obfuscator: ${plugin.label} (detected, ${confidence.toFixed(2)})\n`);

  const outdir = path.join(path.dirname(absInput), 'output');
  fs.mkdirSync(outdir, { recursive: true });

  const tracename = path.basename(absInput).replace(/(\.luau?|\.txt)?$/, '.deobf.luau');
  const os = require('os');
  const workdir = args.debug ? null : fs.mkdtempSync(path.join(os.tmpdir(), 'deobf_node_'));

  const tracePath = args.debug
    ? (args.output || path.join(outdir, tracename))
    : path.join(workdir, tracename);
  const final = (args.output && args.inputs.length === 1)
    ? args.output
    : path.join(outdir, path.basename(absInput));

  fs.mkdirSync(path.dirname(path.resolve(final)), { recursive: true });

  try {
    const fixed = detectModule.restoreHeaderNewline(source);
    let jobSource = source;
    let sourcePath = absInput;

    if (fixed !== source) {
      process.stderr.write('[*] header comment ran into the code: split it\n');
      jobSource = fixed;
      sourcePath = path.join(workdir || outdir, path.basename(absInput) + '.src.lua');
      fs.writeFileSync(sourcePath, fixed, 'latin1');
    }

    const job = new Job(absInput, jobSource, args, tracePath, args.debug, plugin.label);
    job.sourcePath = sourcePath;

    let result;
    if (plugin.name === 'luarmor_client') {
      // Auth-gated loader: control flow is not virtualized, but tracing deadlocks
      // on wall-clock anti-tamper (docs/LUARMOR_NOTES.md §4, §8). Route instead.
      throw new Error(
        'Luarmor whitelist client detected — devirtualization/tracing not applicable. ' +
        'Use tools/luarmor_probe.py to classify and split loader vs payload.'
      );
    } else if (plugin.name === 'luraph_v15') {
      result = await driver.run(job);
    } else {
      result = await driver.runGeneric(job);
    }

    if (final && result && fs.existsSync(result)) {
      let content = fs.readFileSync(result, 'utf8');
      content = content.replace(/^(\s*--(?:[ \t]*(?:Deobfuscated by|Detected obfuscation|Local names are inferred|source:|NOTE: reconstructed|during the trace)[^\n]*\n?|\s*\n))+/, '');
      fs.writeFileSync(final, content, 'utf8');
      process.stderr.write(`[+] result: ${final}\n`);
      return final;
    }
    process.stderr.write(`[!] no result for ${path.basename(absInput)}\n`);
    return null;
  } finally {
    if (workdir && fs.existsSync(workdir)) {
      try { fs.rmSync(workdir, { recursive: true, force: true }); } catch {}
    }
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.inputs.length === 0) {
    console.error('Usage: node deob.js <input.lua | folder> [more_files_or_folders...] [-o <output.lua>] [--plugin <name>] [--no-devirt] [--debug] [--detect]');
    process.exit(2);
  }

  const files = collectInputFiles(args.inputs);
  if (files.length === 0) {
    console.error('[!] no valid .lua / .luau input files found');
    process.exit(1);
  }

  if (args.detect) {
    for (const file of files) {
      const source = fs.readFileSync(file, 'latin1');
      let plugin, confidence;
      if (args.plugin) { plugin = detectModule.byName(args.plugin); confidence = 1.0; }
      else ({ plugin, confidence } = detectModule.detect(source));
      console.log(`${path.basename(file)}\t${plugin.name}\t${confidence.toFixed(2)}\t${plugin.label}`);
    }
    return;
  }

  if (files.length > 1 && args.output) {
    process.stderr.write('[!] --output is ignored for multiple inputs (each file goes into its own output/ folder)\n');
  }

  let succeeded = 0;
  let failed = 0;

  for (const file of files) {
    process.stderr.write(`\n[*] processing ${file}\n`);
    try {
      const res = await processFile(file, args);
      if (res) succeeded++;
      else failed++;
    } catch (err) {
      process.stderr.write(`[!] failed on ${path.basename(file)}: ${err.message || err}\n`);
      failed++;
    }
  }

  process.stderr.write(`\n[*] done: ${succeeded} succeeded, ${failed} failed out of ${files.length}\n`);
  if (failed > 0 && succeeded === 0) process.exit(1);
}

main().catch(err => {
  process.stderr.write('[!] Fatal error: ' + (err.message || err) + '\n');
  process.exit(1);
});
