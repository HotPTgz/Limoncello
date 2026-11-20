import cv2, numpy as np, potrace
from shapely.geometry import Polygon
from shapely.ops import unary_union
from PIL import Image

def load(name):
    g=cv2.imread(name,cv2.IMREAD_GRAYSCALE)
    return g

def trace(g):
    bm=potrace.Bitmap(g>=128)
    return bm.trace(turdsize=20, alphamax=1.0, opticurve=True, opttolerance=0.2)

def flatten(curve, n=12):
    pts=[]
    p=curve.start_point
    pts.append((p.x,p.y))
    for seg in curve.segments:
        if seg.is_corner:
            pts.append((seg.c.x,seg.c.y)); pts.append((seg.end_point.x,seg.end_point.y))
        else:
            a=np.array(pts[-1]); b=np.array([seg.c1.x,seg.c1.y]); c=np.array([seg.c2.x,seg.c2.y]); d=np.array([seg.end_point.x,seg.end_point.y])
            for t in np.linspace(0,1,n+1)[1:]:
                q=(1-t)**3*a+3*(1-t)**2*t*b+3*(1-t)*t**2*c+t**3*d
                pts.append(tuple(q))
    return pts

def svg(path, w, h, fname):
    d=[]
    for curve in path:
        s=curve.start_point; parts=[f"M{s.x:.1f},{s.y:.1f}"]
        for seg in curve.segments:
            if seg.is_corner: parts.append(f"L{seg.c.x:.1f},{seg.c.y:.1f}L{seg.end_point.x:.1f},{seg.end_point.y:.1f}")
            else: parts.append(f"C{seg.c1.x:.1f},{seg.c1.y:.1f} {seg.c2.x:.1f},{seg.c2.y:.1f} {seg.end_point.x:.1f},{seg.end_point.y:.1f}")
        d.append(''.join(parts)+'Z')
    open(fname,'w').write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w//4}" height="{h//4}"><path fill="#000" fill-rule="evenodd" d="{" ".join(d)}"/></svg>\n')

def polygons(path):
    rings=[Polygon(flatten(c)).buffer(0) for c in path]
    # even-odd: build by XOR in order of area (outer first)
    rings=sorted([r for r in rings if r.area>0], key=lambda r:-r.area)
    shape=Polygon()
    for r in rings: shape=shape.symmetric_difference(r)
    return shape
