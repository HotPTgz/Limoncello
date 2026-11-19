# JLCPCB assembly files – 4-key test board

Upload these three files to have JLCPCB make the test board **and** solder its 17 SMD parts.

| File | What it is |
|---|---|
| `LMN_HE_test_gerbers.zip` | Gerbers and drill files (same as the copy one folder up) |
| `LMN_HE_test_BOM_JLCPCB.csv` | BOM: Comment, Designator, Footprint, LCSC Part # |
| `LMN_HE_test_CPL_JLCPCB.csv` | Placement: Designator, Mid X, Mid Y, Layer, Rotation |

Rebuild both CSVs with `python3 ../../main-board/jlcpcb/make_jlcpcb.py test`.

## Parts

| Refs | Part | LCSC | Side |
|---|---|---|---|
| SW1–SW4 | MT9105ET Hall sensor | C967861 | top |
| LED1–LED4 | SK6812MINI-E, reverse mount | C5149201 | bottom |
| U1 | 74AHCT1G125GV | C12494 | bottom |
| C1–C5 | 100 nF 0805 | C49678 | bottom |
| C6 | 22 µF 1206 (instead of 10 µF; larger is fine here) | C12891 | bottom |
| C7 | 1 µF 0805 | C28323 | bottom |
| R1 | 330 Ω 0805 | C17630 | bottom |

Not included (solder by hand): the 1×8 header J1.

## Two ways to order

1. **Everything assembled.** Parts are on both sides, so this needs **Standard** PCBA, *Assembly side: Both sides*. It's the most expensive option, but you only solder the header.
2. **Cheaper: only the bottom side assembled.** Choose *Assembly side: Bottom* and deselect SW1–SW4 on the parts page ("Do not place"). Then hand-solder the 4 Hall sensors on top; four SOT-23s are easy with flux and a fine tip. Check on the order page whether Economic PCBA is offered for a bottom-only job; if not, it's Standard.

As with the main board:
- If the LEDs or another part show 0 stock, pre-order them into your parts library first (see `hardware/main-board/jlcpcb/README.md`).
- In the placement preview, check pin 1 of U1, one sensor and one LED. The rotations are a first guess.
- Run DRC on the test board in your current KiCad first (*Inspect → Design Rules Checker*, with "Refill all zones" ticked).
