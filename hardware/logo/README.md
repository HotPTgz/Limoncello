# Logo

The Limoncello logo (a cello whose body is a lemon) as artwork and as KiCad silkscreen.

| File | What it is |
|---|---|
| `../../docs/images/logo/limoncello_logo.svg` / `.png` | Full logo (icon + name), vector and transparent PNG |
| `../../docs/images/logo/limoncello_icon.svg` / `.png` | Icon only |
| `*_white.png` | White versions for dark backgrounds |
| `logo_bitmap.png` | High-resolution bitmap the footprints are traced from |
| `make_logo_footprints.py` (+ `vec.py`) | Traces the bitmap and writes the KiCad footprints below |

## On the boards

| Board | Footprint | Where |
|---|---|---|
| Main board | `LMN_ext:Limoncello_logo_30mm` (28 × 30 mm) | Top side, between the left speaker and the screen cut-out, centred at (108.5, 62) mm |
| Test board | `LMN_ext:Limoncello_badge_8mm` (32 × 8.5 mm, icon + name) | Bottom side, between the LEDs and the header, centred at (64.5, 57.3) mm |

Both are silkscreen only: they're excluded from the BOM and placement files and touch no copper. Lines are at least about 0.16 mm wide, which JLCPCB's silkscreen can print. On the small test-board badge, the cello's strings print as one solid neck.

To change the size or artwork: edit `make_logo_footprints.py`, run it, then in KiCad use *Update footprint from library* on `LOGO1`.
