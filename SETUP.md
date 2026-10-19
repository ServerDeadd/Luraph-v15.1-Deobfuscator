# Setup & Deobfuscation Tutorial

A practical, step-by-step guide to getting the tool running and using it to
analyze a Luraph v15 / v15.1 script. For *what* each stage does internally, see
[TECHNICAL.md](TECHNICAL.md).

> **Reminder:** this is a defensive analysis tool. Use it to inspect code for
> hidden malware before running it, on code you own or are allowed to review. See
> [Purpose & Legal](README.md#purpose--legal).

---

## 1. Install

### 1.1 Requirements
- **Node.js 18+** — <https://nodejs.org/>
- **Python 3.10+** — <https://www.python.org/>
- **OS:** Windows or Linux. Prebuilt Luau binaries for both are already in `bin/`.

Check they're installed:
```bash
node --version
python --version
```

### 1.2 Get the code
```bash
git clone https://github.com/<your-username>/luraph-v15-deobfuscator.git
cd luraph-v15-deobfuscator
```
There are **no packages to install** — no `npm install`, no `pip install`. The
entry point is plain Node and the Luau binaries ship in the repo.

### 1.3 (Optional) PyPy for ~2× speed
The Python lifting stage runs much faster under PyPy. If you want it, download a
[PyPy 3.10+ build](https://www.pypy.org/download.html) and place it so that:
- **Windows:** `pypy/pypy3.exe` exists
- **Linux:** `pypy/bin/pypy3` exists

The tool auto-detects it. Without it, it just uses CPython. (You can also point at
any PyPy with the `DEOB_PYPY` environment variable.)

### 1.4 If your Python command is different
If `python` / `python3` isn't the right command (e.g. you use `py` or a venv),
set `PYTHON_BIN`:
```bash
# Windows (PowerShell)
$env:PYTHON_BIN = "py"
# Windows (cmd)
set PYTHON_BIN=py
# Linux / macOS
export PYTHON_BIN=python3
```

### 1.5 Smoke test
Run the bundled sample regression to confirm everything works:
```bash
python tests/run_samples.py
```
You should see several `MATCH` lines and `... FAIL (of N)` ending in `0 FAIL`
(one sample may print `DIFF tolerated` — that's expected).

---

## 2. The easy case

Most scripts need **one command**:

```bash
node deob.js path/to/script.lua -o path/to/clean.lua
```

Then optionally strip the leftover obfuscator junk (dead statements the lifter
proved have no effect):

```bash
python luaclean.py bin/luau-ast.exe clean.lua clean_final.lua    # Windows
python luaclean.py bin/luau-ast   clean.lua clean_final.lua      # Linux
```

If `clean.lua` contains the real script logic, **you're done.** Open it and read
it. If instead it only produced a small anti-tamper shell (Path2D,
`DescendantAdded`, ~40 functions) or errored with `size out of range`, the script
is **game-locked** — continue to Section 3.

**Just want a quick safety check?** Use trace mode — it runs the script in the
sandbox and dumps what it *does* (URLs, remotes fired, webhooks, UI) in ~2 seconds:
```bash
node deob.js path/to/script.lua -o trace.lua --no-devirt
```

---

## 3. Game-locked scripts (Luraph v15.1)

Many v15.1 hubs mix `game.GameId` into the decryption key, so the payload only
decrypts if the sandbox pretends to be the right game. Symptoms:

- `run status: script error: ... invalid argument #1 to 'create' (size out of range)`, or
- the output is only the anti-tamper shell (~40 functions, Path2D / DescendantAdded).

### Step 1 — Get the GameId
The GameId is the **universe ID**, *not* the place ID. From the place ID:
```
https://apis.roblox.com/universes/v1/places/<PlaceId>/universe
```
Example — Brookhaven: PlaceId `4924922222` → GameId `1686885941`.

Create `cfg.json`:
```json
{"__superz_game_id": 1686885941, "__superz_place_id": 4924922222}
```

### Step 2 — Confirm the key with a fast trace
```bash
node deob.js script.lua -o trace.lua --no-devirt --cfg-json "@cfg.json"
```
`run status: finished` plus real code in `trace.lua` = correct GameId. If it still
errors, the GameId is wrong (or the hub is delivered/signed per-session from a
server and can't be decrypted offline).

### Step 3 — Find the payload root
In a game-locked script the payload runs in the **same VM** as the shell, so the
default root pick is wrong (you get 1–40 functions). Find where the payload starts:

```bash
node deob.js script.lua -o out.lua --debug --devirt-rounds 1 --cfg-json "@cfg.json"
python tools/seqs.py out.lua.protos.json
```
Look at **"runs by seq"**: the shell is the first protos (e.g. `1–39` or `1–64`);
after a jump the payload begins (e.g. `48` or `65`). Confirm with a known string:

```bash
python tools/findproto.py out.lua.protos.json Path2D       # -> in the shell
python tools/findproto.py out.lua.protos.json MakeWindow    # -> the UI builder
```
`findproto` prints `(seq, id, vm-group)`. If the UI lives in a **different VM group**
with a *lower* seq than the root (e.g. code2's `47`, code3's `90`), pass it in
`DEVIRT_EXTRA_SEQS`. Do **not** use the first proto of a sibling group as the root
if it's the loader (you'll see `luraph_runtime1(fn(...), buffer.fromstring("..."))`
and lots of errors).

### Step 4 — Full devirtualization
Set the roots as environment variables, then run:

```powershell
# Windows PowerShell
$env:DEVIRT_ROOT_SEQ  = "48"   # payload root (from step 3)
$env:DEVIRT_ALL_FROM  = "48"   # also build detached closures created from there
$env:DEVIRT_EXTRA_SEQS = "47"  # extra protos (e.g. UI in a sibling VM), comma-separated
$env:DEVIRT_FULL_ROUNDS = "1"  # full constant rounds
node deob.js script.lua -o out.lua --debug --timeout 900 --budget 300 --devirt-rounds 4 --cfg-json "@cfg.json"
python luaclean.py bin/luau-ast.exe out.lua out_clean.lua
```

```bash
# Linux / macOS
export DEVIRT_ROOT_SEQ=48
export DEVIRT_ALL_FROM=48
export DEVIRT_EXTRA_SEQS=47
export DEVIRT_FULL_ROUNDS=1
node deob.js script.lua -o out.lua --debug --timeout 900 --budget 300 --devirt-rounds 4 --cfg-json "@cfg.json"
python luaclean.py bin/luau-ast out.lua out_clean.lua
```

```cmd
:: Windows cmd uses  set NAME=value
set DEVIRT_ROOT_SEQ=48
```

The driver keeps the **best round** (fewest unlifted blocks). Clear the variables
afterwards — PowerShell: `Remove-Item Env:DEVIRT_*`.

---

## 4. Speed vs. completeness

The lifter's result depends on Python's hash order (`PYTHONHASHSEED`): on the same
input one seed gave 27 unlifted blocks, another 242. So the Python stage runs
several candidates **in parallel** and keeps the best (fewest blocks, then most
functions); if one finishes with 0 blocks the rest stop. It costs about the time of
one run (uses other cores).

| Variable | Default | Effect |
|---|---|---|
| `DEOB_PY_CANDIDATES` | `pypy,python:1,python:2` (or `python:1,python:2,python:3` without PyPy) | Which candidates to race |
| `DEOB_FAST` | off | Only the first candidate (PyPy when present) — fastest, no best-of |
| `DEVIRT_BLOCK_STALL` | `3` | Stop constant rounds after N rounds with no new block recovered |
| `DEVIRT_ROUND_BUDGET` | `240` | Wall-clock cap (seconds) on the constant rounds |

- **Fastest for one script:** `DEOB_FAST=1` and `--devirt-rounds 1` with
  `DEVIRT_FULL_ROUNDS=1`.
- **Most complete:** `DEVIRT_BLOCK_STALL=8` and `DEVIRT_ROUND_BUDGET=600`.
- If the output still has many `error("devirt: ...")` markers, **just run it
  again** — the trace is also timing-dependent (one script went from 20 unlifted
  blocks to 0 on a second run).

---

## 5. Reading the output

| You see | It means |
|---|---|
| `error("devirt: ...")` | A block that couldn't be lifted (fail-loud marker, not real code) |
| `nil`, `(nil).X`, `if nil then` | A value the lifter didn't resolve — **not** dead code |
| `__unresolved_upvalue.X` | Same, written this way so it stays valid Luau |
| `payload_fn_N` | A closure no recovered code references (N = creation order) |
| meaningful local names | Inferred from usage (`Players`, `localPlayer`, `TweenService`, …) |

> `if nil then ... end` is an **unresolved condition**, not dead code — the branch
> body is real. `luaclean.py` deliberately does not delete those.

---

## 6. Diagnostics (off by default, no normal-use cost)

```bash
# Print [pcall-err]/[fatal-ring] with the last proxies created when an error whose
# text matches <substr> happens (finds WHICH read became the userdata that broke a
# comparison and cut off proto capture):
node deob.js script.lua -o out.lua --cfg-json "{\"debug_pcall\":\"<substr>\"}"

# Keep all raw harness output (prints outside the trace):
DEOB_RAW=raw.txt node deob.js script.lua -o out.lua     # Linux
$env:DEOB_RAW="raw.txt"; node deob.js script.lua -o out.lua   # PowerShell
```

See [TECHNICAL.md](TECHNICAL.md) §4 for the complete `DEVIRT_*` / `DEOB_*` list.

---

## 7. Troubleshooting

| Problem | Fix |
|---|---|
| `Python not found` | Install Python 3.10+ or set `PYTHON_BIN` (§1.4) |
| Output is only ~40 functions / `size out of range` | Game-locked — do Section 3 (pass the GameId) |
| Only 1 function lifted on a game-locked script | Wrong root — find the payload seq (§3 step 3) and set `DEVIRT_ROOT_SEQ` |
| Lots of `error("devirt: ...")` left | Run again (timing-dependent), or raise `DEVIRT_BLOCK_STALL` / `DEVIRT_ROUND_BUDGET` |
| UI / part of the script missing | It's in a sibling VM group — add its seq to `DEVIRT_EXTRA_SEQS` |
| Script is a key-gated / auth loader | The payload is delivered only after a live auth handshake and cannot be decrypted offline; use `--no-devirt` to see the loader's behaviour |
| `permission denied` running `bin/luau` on Linux | `chmod +x bin/luau bin/luau-ast` |
