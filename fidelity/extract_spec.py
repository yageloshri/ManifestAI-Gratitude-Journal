#!/usr/bin/env python3
"""Walk a Figma REST nodes JSON and print a compact spec tree.

Usage: extract_spec.py <nodes.json> [rootNodeId]
Prints per node: id, name, type, frame-relative x/y/w/h, fills, strokes,
corner radius, opacity, effects, text style + characters.
"""
import sys, json


def hexcol(c):
    return "#{:02X}{:02X}{:02X}".format(round(c["r"] * 255), round(c["g"] * 255), round(c["b"] * 255))


def paint(p):
    t = p.get("type")
    if not p.get("visible", True):
        return None
    if t == "SOLID":
        a = p.get("opacity", 1)
        s = hexcol(p["color"])
        return s if a == 1 else f"{s}@{a:.3g}"
    if t and t.startswith("GRADIENT"):
        stops = ", ".join(f"{hexcol(s['color'])}{'@%.3g' % s['color'].get('a',1) if s['color'].get('a',1)!=1 else ''}:{s['position']:.4g}" for s in p.get("gradientStops", []))
        return f"{t}[{stops}] handles={[(round(h['x'],3),round(h['y'],3)) for h in p.get('gradientHandlePositions',[])]}"
    if t == "IMAGE":
        return f"IMAGE(ref={p.get('imageRef','')[:12]} mode={p.get('scaleMode')} op={p.get('opacity',1)})"
    return t


def effect(e):
    if not e.get("visible", True):
        return None
    t = e["type"]
    if t in ("DROP_SHADOW", "INNER_SHADOW"):
        o = e.get("offset", {"x": 0, "y": 0})
        return f"{t}({hexcol(e['color'])}@{e['color'].get('a',1):.3g} dx={o['x']:.4g} dy={o['y']:.4g} blur={e.get('radius',0):.4g} spread={e.get('spread',0):.4g})"
    if t in ("LAYER_BLUR", "BACKGROUND_BLUR"):
        return f"{t}({e.get('radius',0):.4g})"
    return t


def walk(n, ox, oy, depth):
    bb = n.get("absoluteBoundingBox") or {}
    x = bb.get("x", 0) - ox
    y = bb.get("y", 0) - oy
    w = bb.get("width", 0)
    h = bb.get("height", 0)
    parts = [f"{'  '*depth}[{n.get('type','?')[:4]}] {n.get('name','')!r} id={n.get('id')}",
             f"xywh=({x:.4g},{y:.4g},{w:.4g},{h:.4g})"]
    if n.get("opacity", 1) != 1:
        parts.append(f"op={n['opacity']:.3g}")
    fills = [paint(p) for p in n.get("fills", []) if paint(p)]
    if fills:
        parts.append("fill=" + "|".join(fills))
    strokes = [paint(p) for p in n.get("strokes", []) if paint(p)]
    if strokes:
        parts.append(f"stroke={'|'.join(strokes)} sw={n.get('strokeWeight')}")
    if n.get("cornerRadius") is not None:
        parts.append(f"r={n['cornerRadius']}")
    if n.get("rectangleCornerRadii"):
        parts.append(f"radii={n['rectangleCornerRadii']}")
    effs = [effect(e) for e in n.get("effects", []) if effect(e)]
    if effs:
        parts.append("fx=[" + "; ".join(effs) + "]")
    if n.get("type") == "TEXT":
        st = n.get("style", {})
        parts.append(f"font={st.get('fontFamily')} {st.get('fontPostScriptName')} {st.get('fontSize')}pt w{st.get('fontWeight')} lh={st.get('lineHeightPx'):.4g}px ls={st.get('letterSpacing',0):.3g} align={st.get('textAlignHorizontal')}/{st.get('textAlignVertical')}")
        parts.append(f"chars={n.get('characters','')!r}")
    print("  ".join(parts))
    for c in n.get("children", []):
        walk(c, ox, oy, depth + 1)


def main():
    data = json.load(open(sys.argv[1]))
    for nid, nd in data["nodes"].items():
        doc = nd["document"]
        bb = doc.get("absoluteBoundingBox") or {}
        print(f"=== ROOT {nid} {doc.get('name')!r} at ({bb.get('x')},{bb.get('y')}) {bb.get('width')}x{bb.get('height')} ===")
        walk(doc, bb.get("x", 0), bb.get("y", 0), 0)


main()
