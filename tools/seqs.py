import json, sys
d = json.load(open(sys.argv[1]))
p = d["protos"]
def mk(v):
    m = v.get("__maker")
    return bytes.fromhex(m["s"]).decode("latin1") if isinstance(m, dict) and "s" in m else str(m)
groups = {}
for k, v in p.items():
    groups.setdefault(mk(v), []).append((v.get("__seq") or 0, k))
for g, lst in groups.items():
    lst.sort()
    seqs = [s for s, _ in lst]
    print(g, len(lst), "seq range", seqs[0], seqs[-1])
    gaps = [(seqs[i], seqs[i + 1]) for i in range(len(seqs) - 1) if seqs[i + 1] - seqs[i] > 5]
    print("   first 12:", lst[:12])
    print("   big gaps:", gaps[:10])
# interleave of groups by seq
allp = sorted((v.get("__seq") or 0, mk(v)[-8:], k) for k, v in p.items())
prev = None
runs = []
for s, g, k in allp:
    if g != prev:
        runs.append([g, s, s, 0])
        prev = g
    runs[-1][2] = s
    runs[-1][3] += 1
print("runs by seq:", runs[:30])
