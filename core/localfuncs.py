import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))


def _ast(text):
    import harness
    with tempfile.NamedTemporaryFile("w", suffix=".luau", delete=False, encoding="utf-8", newline="\n") as f:
        f.write(text)
        path = f.name
    try:
        r = harness.run_luau_ast(path)
        if r.returncode != 0:
            raise SyntaxError("not valid Luau: %s" % r.stderr.decode("latin-1").strip()[:500])
        out = r.stdout
    finally:
        os.remove(path)
    return json.loads(out.decode("latin-1"))["root"]

def _walk(n, fn):
    if isinstance(n, dict):
        fn(n)
        for v in n.values():
            if isinstance(v, (dict, list)):
                _walk(v, fn)
    elif isinstance(n, list):
        for v in n:
            _walk(v, fn)

def rewrite(text):
    root = _ast(text)
    hits = []

    def visit(n):
        if n.get("type") != "AstStatLocal" or len(n.get("vars", [])) != 1 or len(n.get("values", [])) != 1:
            return
        fn = n["values"][0]
        if fn.get("type") != "AstExprFunction":
            return
        var = n["vars"][0]
        refs = []
        _walk(fn, lambda x: refs.append(x) if x.get("type") == "AstExprLocal"
              and x["local"]["location"] == var["location"] else None)
        if not refs:
            l, c = map(int, n["location"].split(" - ")[0].split(","))
            hits.append((l, c, var["name"]))

    _walk(root, visit)
    lines = text.split("\n")
    fixed = 0
    for l, c, name in hits:
        s = lines[l].encode("utf-8")
        head = ("local %s = function(" % name).encode("utf-8")
        if s[c:c + len(head)] == head:
            lines[l] = (s[:c] + ("local function %s(" % name).encode("utf-8") + s[c + len(head):]).decode("utf-8")
            fixed += 1
    if len(hits) > fixed:
        print("[!] local function pass: %d of %d candidate(s) skipped (source offset drift)"
              % (len(hits) - fixed, len(hits)), file=sys.stderr)
    return "\n".join(lines)

if __name__ == "__main__":
    import sys
    p = sys.argv[1]
    with open(p, encoding="utf-8") as f:
        t = f.read()
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write(rewrite(t))
