import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
needle = sys.argv[2].encode().hex()
tables = d.get("tables", {})
print("top keys:", list(d.keys()))
# tables whose serialized form contains the needle
hit_t = [tid for tid, t in tables.items() if needle in json.dumps(t)]
print("tables containing it:", hit_t[:10], len(hit_t))
# parents: tables referencing those tables, up to 3 levels
def parents(tids):
    out = set()
    for tid, t in tables.items():
        s = json.dumps(t)
        for h in tids:
            if '"t": %s}' % h in s or '"t": %s,' % h in s or ('{"t": %s}' % h) in s:
                out.add(tid)
    return out
lvl = set(hit_t)
for depth in range(4):
    caps = []
    for k, cap in d["protos"].items():
        s = cap.get("self")
        if isinstance(s, dict) and str(s.get("t")) in lvl:
            m = cap.get("__maker")
            caps.append((cap.get("__seq"), k, bytes.fromhex(m["s"]).decode() if isinstance(m, dict) and "s" in m else m))
    print("depth", depth, "protos whose self is in set:", sorted(caps)[:10])
    if caps:
        break
    lvl = {str(x) for x in parents(lvl)}
    print("  parent tables:", list(lvl)[:10])
