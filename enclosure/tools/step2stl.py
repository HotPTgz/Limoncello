"""STEP -> STL with OpenCASCADE (OCP). usage: step2stl.py in.step out.stl [deflection_mm]"""
import sys, time
from OCP.STEPControl import STEPControl_Reader
from OCP.BRepMesh import BRepMesh_IncrementalMesh
from OCP.StlAPI import StlAPI_Writer
from OCP.Bnd import Bnd_Box
from OCP.BRepBndLib import BRepBndLib

t0 = time.time()
r = STEPControl_Reader()
st = r.ReadFile(sys.argv[1])
print("read status", st, round(time.time() - t0), "s", flush=True)
r.TransferRoots()
shape = r.OneShape()
print("transferred", round(time.time() - t0), "s", flush=True)
bb = Bnd_Box(); BRepBndLib.Add_s(shape, bb)
print("bbox", [round(v, 3) for v in (bb.CornerMin().X(), bb.CornerMin().Y(), bb.CornerMin().Z(), bb.CornerMax().X(), bb.CornerMax().Y(), bb.CornerMax().Z())], flush=True)
defl = float(sys.argv[3]) if len(sys.argv) > 3 else 0.08
BRepMesh_IncrementalMesh(shape, defl, False, 0.4, True)
print("meshed", round(time.time() - t0), "s", flush=True)
w = StlAPI_Writer(); w.ASCIIMode = False
w.Write(shape, sys.argv[2])
print("wrote", sys.argv[2], round(time.time() - t0), "s", flush=True)
