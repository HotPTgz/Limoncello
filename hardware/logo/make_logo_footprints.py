#!/usr/bin/env python3
"""Turn the Limoncello logo into KiCad silkscreen footprints.

logo_bitmap.png (the logo, black on white) is traced with potrace, cut into
hole-free polygons (KiCad's fp_poly can't have holes) and written as:

  Limoncello_logo_30mm   full logo, 30 mm tall (main board, top side)
  Limoncello_badge_8mm   cello-lemon icon 8.5 mm tall + the word LIMONCELLO
                         beside it (test board, bottom side)

into ../main-board/kicad/LMN_ext.pretty and ../test-board/kicad/LMN_ext.pretty.
Needs: pip install potracer shapely opencv-python
"""
import os, sys
import cv2
from shapely.geometry import Polygon, MultiPolygon, LineString, box
from shapely import affinity

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from vec import trace, polygons

SPLIT_Y = 1976          # bitmap row between the icon and the word
MIN_FEATURE = 0.16      # mm: thicken anything thinner (JLCPCB silk min ~0.15)


def parts(geom):
    return list(geom.geoms) if hasattr(geom, "geoms") else [geom]


def fracture(geom):
    """Cut every polygon with holes vertically through each hole -> no holes."""
    out = []
    for p in parts(geom):
        if p.is_empty or p.area < 1e-6:
            continue
        if not p.interiors:
            out.append(p)
            continue
        # a vertical slit (2 um, far below what can be printed) through the
        # first hole opens it; repeat until no holes are left
        x = Polygon(p.interiors[0]).representative_point().x
        minx, miny, maxx, maxy = p.bounds
        slit = box(x - 0.001, miny - 1, x + 0.001, maxy + 1)
        out.extend(fracture(p.difference(slit)))
    return out


def to_mm(geom, height_mm, ref_height_px):
    s = height_mm / ref_height_px
    g = affinity.scale(geom, s, s, origin=(0, 0))
    # keep only real shapes, thicken hairlines, and tidy
    g = g.buffer(MIN_FEATURE / 4, join_style=1).buffer(-MIN_FEATURE / 4 + 0.01, join_style=1)
    return g.simplify(0.01)


def center(geom):
    minx, miny, maxx, maxy = geom.bounds
    return affinity.translate(geom, -(minx + maxx) / 2, -(miny + maxy) / 2)


def write_fp(path, name, geom, descr):
    polys = fracture(geom)
    lines = [f'(footprint "{name}" (version 20221018) (generator pcbnew)',
             '  (layer "F.Cu")',
             f'  (descr "{descr}")',
             '  (attr board_only exclude_from_pos_files exclude_from_bom)',
             '  (fp_text reference "LOGO**" (at 0 0) (layer "F.SilkS") hide (effects (font (size 1 1) (thickness 0.15))))',
             f'  (fp_text value "{name}" (at 0 2) (layer "F.Fab") hide (effects (font (size 1 1) (thickness 0.15))))']
    for p in polys:
        pts = list(p.exterior.coords)[:-1]
        xy = " ".join(f"(xy {x:.4f} {y:.4f})" for x, y in pts)
        lines.append(f'  (fp_poly (pts {xy}) (stroke (width 0) (type solid)) (fill solid) (layer "F.SilkS"))')
    lines.append(")")
    open(path, "w").write("\n".join(lines) + "\n")
    minx, miny, maxx, maxy = geom.bounds
    print(f"{name}: {len(polys)} polygons, {maxx - minx:.1f} x {maxy - miny:.1f} mm")


def main():
    g = cv2.imread(os.path.join(HERE, "logo_bitmap.png"), cv2.IMREAD_GRAYSCALE)
    full = polygons(trace(g)).buffer(0)
    minx, miny, maxx, maxy = full.bounds
    icon = full.intersection(box(minx - 1, miny - 1, maxx + 1, SPLIT_Y))
    word = full.intersection(box(minx - 1, SPLIT_Y, maxx + 1, maxy + 1))

    logo30 = center(to_mm(full, 30.0, maxy - miny))

    # badge: icon 8.5 mm tall, word 2.6 mm tall to its right, both centred
    ib = icon.bounds
    icon_mm = center(to_mm(icon, 8.5, ib[3] - ib[1]))
    wb = word.bounds
    word_mm = center(to_mm(word, 2.6, wb[3] - wb[1]))
    iw = icon_mm.bounds[2] - icon_mm.bounds[0]
    ww = word_mm.bounds[2] - word_mm.bounds[0]
    icon_mm = affinity.translate(icon_mm, -(iw + 1.5 + ww) / 2 + iw / 2, 0)
    word_mm = affinity.translate(word_mm, -(iw + 1.5 + ww) / 2 + iw + 1.5 + ww / 2, 0)
    badge = icon_mm.union(word_mm)

    for board in ("main-board", "test-board"):
        lib = os.path.join(HERE, "..", board, "kicad", "LMN_ext.pretty")
        write_fp(os.path.join(lib, "Limoncello_logo_30mm.kicad_mod"), "Limoncello_logo_30mm", logo30,
                 "Limoncello logo, silkscreen, 30 mm tall")
        write_fp(os.path.join(lib, "Limoncello_badge_8mm.kicad_mod"), "Limoncello_badge_8mm", badge,
                 "Limoncello icon + name, silkscreen, 8.5 mm tall")


if __name__ == "__main__":
    main()
