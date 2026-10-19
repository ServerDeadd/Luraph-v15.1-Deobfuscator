'use strict';

const KEYWORDS = new Set([
  'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'if', 'in',
  'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while', 'continue'
]);

function stripMarkers(text) {

  return text.replace(/--@\S*\n?/g, '');
}

function stripPreamble(text) {

  const lines = text.split('\n');
  let cut = 0;

  for (let i = 0; i < Math.min(lines.length, 120); i++) {
    const l = lines[i];
    if (l.includes('Path2D:GetTangentOnCurveArcLength') || l.includes('ScreenGui:Destroy()')) {
      cut = i + 1;
    }
  }
  if (cut > 0) {
    return lines.slice(cut).join('\n').replace(/^\n+/, '');
  }
  return text;
}

function space(text) {

  const lines = text.split('\n');
  const out = [];
  for (let i = 0; i < lines.length; i++) {
    const l = lines[i];
    const prev = out[out.length - 1] || '';
    const isBlockStart = /^\t*(local function|function |if |for |while )/.test(l);
    const prevIsBlank = prev.trim() === '';
    const prevIsBlockStart = /^\t*(local function|function |if |for |while |local )/.test(prev);
    if (isBlockStart && !prevIsBlank && !prevIsBlockStart && i > 0) {

    }
    out.push(l);
  }
  return out.join('\n');
}

function stripAnnotations(text) {
  const lines = text.split('\n');
  const clean = [];
  let inUrlList = false;

  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('-- URLs requested:') ||
        trimmed.startsWith('-- remotes fired/invoked:') ||
        trimmed.startsWith('-- non-standard globals touched:') ||
        trimmed.startsWith('-- anti-tamper trap')) {
      inUrlList = true;
      continue;
    }
    if (inUrlList) {
      if (trimmed.startsWith('--   ') || trimmed === '--') continue;
      inUrlList = false;
    }
    if (trimmed.startsWith('-- [envlog]') ||
        trimmed.startsWith('-- isfolder(') ||
        trimmed.startsWith('-- isfile(') ||
        trimmed.startsWith('-- identifyexecutor(') ||
        trimmed.startsWith('-- condition:') ||
        trimmed.startsWith('-- loadstring() of') ||
        trimmed.startsWith('-- run status:') ||
        /^--\s*\d+\s+statements recorded/.test(trimmed)) {
      continue;
    }
    clean.push(line);
  }
  return clean.join('\n').replace(/^\n+/, '');
}

function tidy(text, options = {}) {
  let res = stripMarkers(text);
  res = stripAnnotations(res);
  if (options.preamble !== false) {
    res = stripPreamble(res);
  }
  return space(res);
}

module.exports = { tidy, stripMarkers, stripPreamble, stripAnnotations, space };
