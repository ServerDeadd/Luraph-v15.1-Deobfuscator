from localfuncs import _ast, _walk

EXITS = ("AstStatReturn", "AstStatBreak", "AstStatContinue")

def _lines(st):
    a, b = st["location"].split(" - ")
    return int(a.split(",")[0]), int(b.split(",")[0])

def _is_guard(st):
    if st["type"] != "AstStatIf" or st.get("elsebody"):
        return False
    body = st["thenbody"]["body"]
    if not body or len(body) > 2 or body[-1]["type"] not in EXITS:
        return False
    l1, l2 = _lines(st)
    return l2 - l1 <= 4

def _kind(st, top):
    """'big', 'guard' or 'small'."""
    l1, l2 = _lines(st)
    if l1 == l2:
        return "small"
    if not top and _is_guard(st):
        return "guard"
    return "big"

def blank_lines_after(root):
    """0-based line numbers after which a blank line goes."""
    out = set()

    def block(blk, top):
        body = blk.get("body") or []
        kinds = [_kind(st, top) for st in body]
        for i in range(1, len(body)):
            a, b = kinds[i - 1], kinds[i]
            if a == "big" or b == "big" or (a == "guard" and b == "guard"):
                end_a = _lines(body[i - 1])[1]
                if end_a < _lines(body[i])[0]:
                    out.add(end_a)

    block(root, True)
    _walk(root, lambda n: block(n, False) if n is not root and n.get("type") == "AstStatBlock" else None)
    return out

def space(text):
    try:
        after = blank_lines_after(_ast(text))
    except Exception:  
        return text
    lines = text.split("\n")
    out = []
    for i, s in enumerate(lines):
        out.append(s)
        if i in after and i + 1 < len(lines) and lines[i + 1].strip() != "":
            out.append("")
    return "\n".join(out)

if __name__ == "__main__":
    import sys
    p = sys.argv[1]
    with open(p, encoding="utf-8") as f:
        t = f.read()
    with open(p, "w", encoding="utf-8", newline="\n") as f:
        f.write(space(t))
