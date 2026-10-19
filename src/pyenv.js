'use strict';

const { execFileSync } = require('child_process');

let _cachedPython = null;

function getPythonBin() {
  if (_cachedPython) return _cachedPython;
  if (process.env.PYTHON_BIN) {
    _cachedPython = process.env.PYTHON_BIN;
    return _cachedPython;
  }
  const candidates = process.platform === 'win32'
    ? ['python', 'py', 'python3']
    : ['python3', 'python'];

  for (const cmd of candidates) {
    try {
      execFileSync(cmd, ['--version'], { stdio: 'ignore' });
      _cachedPython = cmd;
      return cmd;
    } catch {}
  }
  throw new Error('Python not found. Please install Python 3.10+ or set the PYTHON_BIN environment variable.');
}

module.exports = { getPythonBin };
