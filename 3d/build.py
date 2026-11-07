#!/usr/bin/env python3
"""Build IRIS 3D files.

  python3 3d/build.py

Needs: openscad (2021.01+), numpy, and a three.js copy (see THREE_DIR below).
Output:
  3d/stl/iris_<part>.stl   binary STL, oriented for 3D printing (min corner at 0,0,0)
  3d/stl/iris_assembly.stl full assembly, drawers closed (for reference)
  3d/iris_viewer.html      single-file interactive 3D viewer (works offline)
"""
import base64, json, os, re, subprocess, sys, tempfile
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "iris.scad")
STL_DIR = os.path.join(HERE, "stl")
THREE_DIR = os.environ.get("THREE_DIR", os.path.join(HERE, "vendor", "three"))

PRINT_PARTS = ["body", "lid", "module", "drawer1", "drawer2", "rack", "pinion"]
VIEW_PARTS = ["module", "body", "lid", "lcd", "drawer1", "drawer2", "rack", "pinion", "servo"]

# keep in sync with iris.scad
W, D, HD, HE, WALL = 200, 100, 50, 60, 2.5
BAY_W = (W - 3 * WALL) / 2
BAYC = [WALL + BAY_W / 2, W - WALL - BAY_W / 2]
SRV_X, SRV_Y = 3 + 1.5 * 13 / 2, 62
BODY_TOP = 19 - 13.4 + 22.7
PR = 1.5 * 13 / 2
TRAVEL = float(np.pi * PR)


def render(part, print_mode, out_path):
    with tempfile.TemporaryDirectory() as td:
        tmp = os.path.join(td, "o.stl")
        cmd = ["openscad", "-D", f'part="{part}"', "-D", f"print={'true' if print_mode else 'false'}",
               "-o", tmp, SCAD]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0 or "WARNING" in r.stderr.upper() and "ignored" in r.stderr.lower():
            sys.stderr.write(r.stderr)
        tris = parse_ascii_stl(tmp)
    return tris


def parse_ascii_stl(path):
    txt = open(path).read()
    v = re.findall(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)", txt)
    a = np.array(v, dtype=np.float64).reshape(-1, 3, 3)
    return a


def write_binary_stl(tris, path):
    n = len(tris)
    a = tris.astype(np.float32)
    nrm = np.cross(a[:, 1] - a[:, 0], a[:, 2] - a[:, 0])
    ln = np.linalg.norm(nrm, axis=1, keepdims=True)
    ln[ln == 0] = 1
    nrm = (nrm / ln).astype(np.float32)
    rec = np.zeros(n, dtype=[("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])
    rec["n"], rec["v"] = nrm, a
    with open(path, "wb") as f:
        f.write(b"IRIS enclosure".ljust(80, b" "))
        f.write(np.uint32(n).tobytes())
        f.write(rec.tobytes())


def is_watertight(tris):
    q = np.round(tris.reshape(-1, 3), 4)
    _, idx = np.unique(q, axis=0, return_inverse=True)
    t = idx.reshape(-1, 3)
    e = np.concatenate([t[:, [0, 1]], t[:, [1, 2]], t[:, [2, 0]]])
    e.sort(axis=1)
    _, c = np.unique(e, axis=0, return_counts=True)
    return bool((c == 2).all())


def main():
    os.makedirs(STL_DIR, exist_ok=True)
    print("== STL (print orientation)")
    for p in PRINT_PARTS:
        t = render(p, True, None)
        t = t - t.reshape(-1, 3).min(axis=0)
        write_binary_stl(t, os.path.join(STL_DIR, f"iris_{p}.stl"))
        bb = t.reshape(-1, 3).max(axis=0)
        print(f"  {p:8s} {len(t):6d} tri  {bb[0]:6.1f} x {bb[1]:6.1f} x {bb[2]:6.1f} mm  watertight={is_watertight(t)}")
    t = render("assembly", False, None)
    write_binary_stl(t, os.path.join(STL_DIR, "iris_assembly.stl"))
    print(f"  assembly {len(t)} tri")

    print("== viewer")
    parts = {}
    for p in VIEW_PARTS:
        t = render(p, False, None)
        q = np.round(t.reshape(-1) * 100).astype(np.int16)
        parts[p] = base64.b64encode(q.tobytes()).decode()
    three = open(os.path.join(THREE_DIR, "build", "three.min.js")).read()
    orbit = open(os.path.join(THREE_DIR, "examples", "js", "controls", "OrbitControls.js")).read()
    cfg = dict(bayc=BAYC, srv_x=SRV_X, srv_y=SRV_Y, body_top=BODY_TOP, pr=PR, travel=TRAVEL,
               hd=HD, he=HE, w=W, d=D)
    html = open(os.path.join(HERE, "viewer_template.html")).read()
    html = (html.replace("/*THREE*/", three).replace("/*ORBIT*/", orbit)
                .replace("/*PARTS*/", json.dumps(parts)).replace("/*CFG*/", json.dumps(cfg)))
    out = os.path.join(HERE, "iris_viewer.html")
    open(out, "w").write(html)
    print(f"  {out}  {os.path.getsize(out)/1e6:.1f} MB")


if __name__ == "__main__":
    main()
