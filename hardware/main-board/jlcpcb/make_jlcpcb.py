#!/usr/bin/env python3
"""Build JLCPCB assembly files (BOM + CPL) for the Limoncello main board, rev C.

Reads ../LMN_v3_revC_BOM.csv and ../LMN_v3_revC_positions.csv and writes:
  LMN_v3_revC_BOM_JLCPCB.csv  - Comment, Designator, Footprint, LCSC Part #
  LMN_v3_revC_CPL_JLCPCB.csv  - Designator, Mid X, Mid Y, Layer, Rotation

Only the SMD parts are included. Through-hole parts (Teensy, Pi socket,
Codec Zero header, encoders, joystick, jack, mic, JST headers) are soldered
by hand, so they are left out on purpose.

Rotations: KiCad and JLCPCB use different "zero" orientations for some
packages. The offsets below are the usual corrections (the same ones the
kicad-jlcpcb-tools plugin uses). They are a starting point only: always
check every part in JLCPCB's placement preview before paying.

Run:  python3 make_jlcpcb.py                 (main board)
      python3 make_jlcpcb.py test            (4-key test board)
"""
import csv
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if len(sys.argv) > 1 and sys.argv[1] == "test":
    TB = os.path.join(HERE, "..", "..", "test-board")
    SRC_BOM = os.path.join(TB, "LMN_HE_test_BOM.csv")
    SRC_POS = os.path.join(TB, "LMN_HE_test_positions.csv")
    OUT_BOM = os.path.join(TB, "jlcpcb", "LMN_HE_test_BOM_JLCPCB.csv")
    OUT_CPL = os.path.join(TB, "jlcpcb", "LMN_HE_test_CPL_JLCPCB.csv")
else:
    SRC_BOM = os.path.join(HERE, "..", "LMN_v3_revC_BOM.csv")
    SRC_POS = os.path.join(HERE, "..", "LMN_v3_revC_positions.csv")
    OUT_BOM = os.path.join(HERE, "LMN_v3_revC_BOM_JLCPCB.csv")
    OUT_CPL = os.path.join(HERE, "LMN_v3_revC_CPL_JLCPCB.csv")

# Value (as in the KiCad BOM) -> (comment for JLCPCB, LCSC part, note)
# B = JLCPCB "Basic" part (no loading fee), E = "Extended" part (loading fee per line).
LCSC = {
    "100nF":       ("100nF 50V X7R 0805",            "C49678",   "B  YAGEO CC0805KRX7R9BB104"),
    "22uF 10V":    ("22uF 25V X5R 1206",             "C12891",   "B  Samsung CL31A226KAHNNNE (25 V is fine for 10 V)"),
    "10uF":        ("22uF 25V X5R 1206",             "C12891",   "B  test board C6: 22 uF in place of 10 uF (bulk decoupling, larger is fine)"),
    "0.47uF":      ("470nF 50V X7R 0805",            "C2991591", "E  FH 0805B474K500AT"),
    "1uF":         ("1uF 50V X7R 0805",              "C28323",   "B  Samsung CL21B105KBFNNNE"),
    "330R":        ("330R 1% 0805",                  "C17630",   "   UNI-ROYAL 0805W8F3300T5E"),
    "82k":         ("82k 5% 0805",                   "C294742",  "E  FH RS-05K823JT"),
    "100k":        ("100k 1% 0805",                  "C149504",  "B  UNI-ROYAL 0805W8F1003T5E"),
    "10k":         ("10k 1% 0805",                   "C17414",   "B  UNI-ROYAL 0805W8F1002T5E"),
    "2N7002":      ("2N7002",                        "C8545",    "B  CJ 2N7002"),
    "74AHCT1G125": ("74AHCT1G125GV",                 "C12494",   "E  Nexperia 74AHCT1G125GV,125"),
    "AMS1117-3.3": ("AMS1117-3.3",                   "C6186",    "B  AMS AMS1117-3.3"),
    "PAM8403DR":   ("PAM8403",                       "C5122557", "E  Slkor PAM8403 (pin-compatible with Diodes PAM8403DR)"),
    "74HC4051":    ("74HC4051D",                     "C2673644", "E  Toshiba 74HC4051D (alt: Nexperia C9386)"),
    "MT9105ET":    ("MT9105ET",                      "C967861",  "E  Magn Tek MT9105ET"),
    "SK6812MINI-E": ("SK6812MINI-E",                 "C5149201", "E  OPSCO SK6812MINI-E (reverse mount)"),
}

# Footprint -> rotation offset (degrees) added to KiCad's rotation.
ROT_OFFSET = [
    (r"^SOT-223", 180),
    (r"^SOT-23", 180),          # also matches SOT-23-5
    (r"^SW_MX_HE_SOT23", 180),  # MT9105ET in a SOT-23
    (r"^SOIC-", 270),
    (r"^SOP-", 270),
]


def rot_offset(fp):
    for pat, off in ROT_OFFSET:
        if re.match(pat, fp):
            return off
    return 0


def main():
    with open(SRC_BOM, newline="") as f:
        bom = list(csv.DictReader(f))
    with open(SRC_POS, newline="") as f:
        pos = {r["Designator"]: r for r in csv.DictReader(f)}

    placed = set()
    bom_rows = []
    for r in bom:
        val = r["Value"]
        if val not in LCSC:
            continue
        comment, part, _note = LCSC[val]
        refs = r["References"].split()
        placed.update(refs)
        bom_rows.append([comment, ",".join(refs), r["Footprint"], part])

    with open(OUT_BOM, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["Comment", "Designator", "Footprint", "LCSC Part #"])
        w.writerows(bom_rows)

    def natkey(ref):
        m = re.match(r"([A-Z]+)(\d+)", ref)
        return (m.group(1), int(m.group(2))) if m else (ref, 0)

    with open(OUT_CPL, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["Designator", "Mid X", "Mid Y", "Layer", "Rotation"])
        for ref in sorted(placed, key=natkey):
            p = pos[ref]
            rot = (float(p["Rotation"]) + rot_offset(p["Package"])) % 360
            layer = "Top" if p["Layer"] == "top" else "Bottom"
            w.writerow([ref, f"{float(p['Mid X']):.3f}mm", f"{float(p['Mid Y']):.3f}mm",
                        layer, f"{rot:g}"])

    n = len(placed)
    top = sum(1 for r in placed if pos[r]["Layer"] == "top")
    print(f"{len(bom_rows)} BOM lines, {n} placements ({top} top, {n - top} bottom)")


if __name__ == "__main__":
    main()
