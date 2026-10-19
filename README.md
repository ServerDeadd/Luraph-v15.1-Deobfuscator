# Luraph v15 / v15.1 Deobfuscator

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-green.svg)](https://nodejs.org/)
[![Python](https://img.shields.io/badge/Python-3.10%2B-green.svg)](https://www.python.org/)
[![Target](https://img.shields.io/badge/Target-Luraph%20v15%20%2F%20v15.1-red.svg)](#)

# STAR THIS PROJECT!


A standalone **defensive analysis tool** that recovers readable Luau source from
scripts protected by **Luraph v15 / v15.1** (the VM obfuscator most commonly seen
on Roblox exploit scripts, "hubs", and loaders).

> **Why this exists.** Obfuscated Lua/Luau scripts are run blindly by thousands of
> people every day. A Luraph-protected script can hide anything: token/cookie
> stealers, Discord-webhook exfiltration, backdoors, remote-code loaders, or
> silent account takeovers. This project's only goal is to let you **see what a
> script actually does before you run it** — i.e. to analyze any malware or virus
> that may be hidden inside executed Lua code. It is a reverse-engineering /
> malware-analysis tool, not a tool for stealing or cracking anyone's work.
> Please read [Purpose & Legal](#purpose--legal) below.

---

## What it does

Luraph v15 compiles a Luau script into an interpreted virtual machine: a flattened
dispatch loop, encrypted in-memory constant buffers (`LPH_ENCSTR`, `LPH_ENCFUNC`),
and anti-tamper traps (`LPH_CRASH()`) that corrupt the bytecode and spin forever
if the environment looks wrong.

This tool works as a **reverse compiler**:

- Runs the script inside an **offline Roblox/Luau sandbox** (`runtime/envlog.luau`) —
  no Roblox client, no executor, no network needed.
- **Decrypts** the lazy constants live by querying that sandboxed VM over an IPC pipe.
- **Lifts the VM bytecode** back to real control flow (`if/elseif/else`, `while`,
  `for`, `for-in`, `repeat/until`) and closures.
- **Names** locals from their Roblox-API usage (`Players`, `TweenService`,
  `ReplicatedStorage`, …) and verifies the output compiles.

The result is clean, readable Luau you can audit.

```
Protected Luraph script
        │
        ▼  1. AST hooking            map the VM dispatch + closure makers (luau-ast)
        ▼  2. Sandboxed simulation   run offline; isolate anti-tamper traps
        ▼  3. Live constant decrypt  query the in-memory VM to decrypt constants
        ▼  4. CFG / SSA lifting      rebuild loops and branches, assign registers
        ▼  5. Polish & naming        infer local names, verify it compiles
        │
        ▼
Readable Luau source
```

For the full methodology (opcode dispatch, SCCP symbolic evaluation, SSA register
webs) see **[TECHNICAL.md](TECHNICAL.md)**.

---

## Features

- **Full devirtualization**, not just a behaviour log — recovers high-level control
  flow, closures and scoping.
- **Offline Roblox sandbox**: models for Roblox services, executor globals, and
  datatypes (`Vector3`, `CFrame`, `UDim2`, `Path2D`, `BrickColor`, …). No game needed.
- **v15.1 game-locked scripts**: many hubs mix `game.GameId` into the decryption
  key. Pass the target's GameId with `--cfg-json` and the payload decrypts (see
  [SETUP.md](SETUP.md)).
- **Best-of-N lifting**: the lifter's output depends on Python's hash seed, so the
  Python stage runs several candidates in parallel and keeps the best (fewest
  unlifted blocks). Optional bundled **PyPy** makes it ~2× faster.
- **Fail-loud**: a block that cannot be lifted becomes an explicit
  `error("devirt: ...")` marker instead of silently emitting wrong code.
- **Self-contained & cross-platform**: Luau binaries for Windows *and* Linux are
  bundled in `bin/`. Works out of the box on both.
- **Fast trace mode** (`--no-devirt`): ~2 s dump of URLs fetched, remotes fired,
  webhooks and UI setup — enough to spot a malicious script immediately.

---

## Quick start

### Prerequisites
- **Node.js** 18+
- **Python** 3.10+
- **OS:** Windows or Linux (both ship with prebuilt `bin/luau` binaries)

### Install
```bash
git clone https://github.com/ServerDeadd/luraph-v15-deobfuscator.git
cd luraph-v15-deobfuscator
```
There are **no npm dependencies** — the entry point is plain Node, and the Luau
binaries are already in `bin/`. (Optional: drop a PyPy build in `pypy/` for a ~2×
speedup; the tool auto-detects it and falls back to CPython when it's absent.)

### Run
```bash
# Deobfuscate one script (default output: ./output/<name> next to the input)
node deob.js input.lua

# Choose the output path
node deob.js input.lua -o clean.lua

# Whole folder, or several files at once
node deob.js ./scripts_folder/
node deob.js a.lua b.lua c.lua

# Fast behaviour trace only (~2 s, no bytecode lifting) — great for a first look
node deob.js input.lua --no-devirt

# Just detect the obfuscator, don't run anything
node deob.js input.lua --detect
```

> If your Python is not on `python`/`python3`, set `PYTHON_BIN`:
> ```bash
> set PYTHON_BIN=py            # Windows (cmd)
> $env:PYTHON_BIN = "py"       # Windows (PowerShell)
> export PYTHON_BIN=python3    # Linux / macOS
> ```

**Stuck on a v15.1 hub that only dumps a ~40-function anti-tamper shell, or errors
with `size out of range`?** That script is game-locked. See the step-by-step
**[SETUP.md](SETUP.md)** — it covers finding the GameId, locating the payload root,
and the environment variables for a full lift.

---

## Command-line options

| Option | Default | Description |
|---|---|---|
| `-o, --output <file>` | `./output/<name>` | Output path (single input only) |
| `--no-devirt` | off | Fast execution trace only (skip VM bytecode lifting) |
| `--no-hooks` | off | Disable VM closure-entry instrumentation |
| `--no-fold` | off | Disable loop/helper folding in trace mode |
| `--detect` | off | Print the detected obfuscator + confidence, then exit |
| `--timeout <sec>` | `90` | Hard timeout per Luau execution pass |
| `--budget <sec>` | `30` | Soft runtime budget for the sandboxed script |
| `--max-runs <n>` | `12` | Max reruns while isolating anti-tamper traps |
| `--devirt-rounds <n>` | `200` | Max live constant-decryption rounds |
| `--cfg-json <json\|@file>` | — | Extra harness config (e.g. the GameId) as inline JSON or `@file.json` |
| `--debug` | off | Keep intermediate disassembly/trace files next to the output |

A fuller environment-variable reference (`DEVIRT_*`, `DEOB_*`) is in
[TECHNICAL.md](TECHNICAL.md) §4 and [SETUP.md](SETUP.md).

---

## Samples & regression test

The `samples_v15.1_deobfuscated/` folder holds public v15.1 inputs
(`*_obfuscated.lua`) next to their expected results (`*_Deobfuscated.lua`). The
regression runner deobfuscates each one and compares byte-for-byte:

```bash
python tests/run_samples.py      # byte-exact sample regression (needs node + bin/luau)
python tests/test_datatypes.py   # offline datatype models vs Studio-verified values
bin/luau tests/test_for_lowering.luau   # for-loop lowering formulas vs real Luau
```

> One sample (`99ba879f8b2ec51c`) can differ by a single, *more complete* function
> depending on Python's hash seed / which parallel candidate wins. That is a known,
> tolerated non-determinism, not a regression — the runner treats it as a pass.

---

## How long does it take?

| Script | Functions | Typical time |
|---|---|---|
| Micro script | 1–20 | 1–5 s |
| Medium hub | 50–200 | 15–35 s |
| Large game / complex | 500–750+ | 1–2 min |
| **Any** (`--no-devirt`) | any | 1–3 s |

Luraph v15 is a *virtual machine*, not simple encryption, so a full lift
symbolically walks thousands of instruction paths, decrypts 2,000–2,600 constants
live, rebuilds the control-flow graph, and renames registers across 10,000+ lines.
If you only need to know *what a script does*, use `--no-devirt`.

---

## Repository layout

```
deob.js                 entry point (node deob.js ...)
src/                    Node driver: sandbox tracing, VM hooks, parallel candidates
core/                   Python core: the devirtualizer / lifter / code generator
  obfuscators/luraph_v15/   devirt.py, driver.py, vmmap.py  (the v15/v15.1 engine)
runtime/envlog.luau     the offline Roblox sandbox the script runs in
runtime/datatypes.luau  offline Vector3/CFrame/UDim2/Path2D/BrickColor models
bin/                    prebuilt Luau 0.739 binaries (Windows + Linux)
luaclean.py             removes proven-dead Luraph junk from the output
build_luau.py           rebuilds the patched Luau runtime from source
tools/seqs.py           show proto creation order (find where the payload starts)
tools/findproto.py      find which proto holds a given string (e.g. the UI)
tests/                  regression + unit tests
samples_v15.1_deobfuscated/   public samples + their reference outputs
protocol.json           harness protocol constants shared by Node / Python / Luau
```

---

## Rebuilding the Luau binaries (optional)

`bin/` already contains working binaries. To rebuild them from the official Luau
0.739 source with the sandbox patches applied:

```bash
python build_luau.py
```
This needs a C++ toolchain and `cmake` (or `zig` as the compiler). It is **not**
required to use the tool — only if you want to verify or modify the runtime.

---

## Purpose & Legal

**Intended use — defensive only.** This project is published so that researchers,
script reviewers and ordinary users can **analyze obfuscated Lua/Luau code for
hidden malware** (token stealers, data-exfiltration webhooks, backdoors, remote
loaders) *before* executing it, and for education about VM-based obfuscation. It
reveals behaviour that is otherwise deliberately hidden.

Use it only on code you own, have permission to analyze, or are reviewing for
safety. **You** are responsible for how you use it. Do not use it to infringe
anyone's intellectual property, to violate the terms of service of any platform,
or for any unlawful purpose.

This is an independent project. It is **not affiliated with, endorsed by, or
connected to Luraph / lura.ph, Roblox Corporation, or any script author.** All
product names, trademarks and registered trademarks are the property of their
respective owners and are used here only to describe the format being analyzed.

**Open source under the [MIT License](LICENSE).** The software is provided
"AS IS", **without warranty of any kind**, express or implied. In no event shall
the authors or copyright holders be liable for any claim, damages or other
liability arising from the use of this software. See [LICENSE](LICENSE) for the
full text.

---

## Credits

- Luraph v15.1 Deobfuscator (serversadzzz) on discord!
