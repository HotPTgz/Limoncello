# JLCPCB assembly files – main board rev C

These files let JLCPCB make the main board **and** solder the surface-mount parts.

| File | What it is |
|---|---|
| `../LMN_v3_revC_gerbers.zip` | Gerbers and drill files (upload first) |
| `LMN_v3_revC_BOM_JLCPCB.csv` | BOM: Comment, Designator, Footprint, LCSC Part # |
| `LMN_v3_revC_CPL_JLCPCB.csv` | Placement (CPL): Designator, Mid X, Mid Y, Layer, Rotation |
| `make_jlcpcb.py` | Rebuilds both CSVs from the KiCad exports one folder up. Change part numbers here. |

The BOM has the **173 SMD parts** (15 lines): 46 on the top side and 127 on the bottom side. The through-hole parts are left out on purpose. You solder those yourself: Teensy, Pi socket, Codec Zero header, encoders, joystick, jack, mic and JST headers.

## Parts

LCSC numbers looked up in November 2026. *B* = JLCPCB Basic part (no setup fee); *E* = Extended part (a small loading fee per line).

| Refs | Part | LCSC | Type | Notes |
|---|---|---|---|---|
| C1–C46, C59–C65 (53) | 100 nF 50 V X7R 0805 | C49678 | B | YAGEO |
| C47–C50, C54, C55 | 22 µF 25 V X5R 1206 | C12891 | B | Rated 25 V, which is more than the 10 V needed |
| C51, C52 | 470 nF 50 V X7R 0805 | C2991591 | E | |
| C53, C56, C57 | 1 µF 50 V X7R 0805 | C28323 | B | |
| R1 | 330 Ω 1 % 0805 | C17630 | | |
| R2, R3 | 82 kΩ 5 % 0805 | C294742 | E | Swap for any in-stock 82 k 0805 |
| R4, R5, R7 | 100 kΩ 1 % 0805 | C149504 | B | |
| R6 | 10 kΩ 1 % 0805 | C17414 | B | |
| Q1 | 2N7002 SOT-23 | C8545 | B | |
| U7 | 74AHCT1G125GV SOT-753 | C12494 | E | LED level shifter |
| U8 | AMS1117-3.3 SOT-223 | C6186 | B | |
| U9 | PAM8403 SOP-16 | C5122557 | E | Slkor version, same pinout as the Diodes PAM8403DR |
| U10–U15 | 74HC4051D SOIC-16 | C9386 | E | Nexperia |
| SW1–SW46 | MT9105ET SOT-23 (top side) | C967861 | E | Hall sensors |
| LED1–LED46 | SK6812MINI-E (bottom side, reverse mount) | C5149201 | E | |

**Stock changes daily.** JLCPCB checks stock live when you upload the BOM. If a part shows as out of stock, pick an equivalent in the same package (same value, same or higher voltage), then update `make_jlcpcb.py`. The tightest lines are the MT9105ET (a few thousand in stock) and the Slkor PAM8403 (a few hundred to a few thousand). For one board you need 46 and 1 of them.

## Rotations: check them

KiCad and JLCPCB use a different "zero" for some packages. The script adds the usual corrections: SOT-23 / SOT-23-5 / SOT-223 +180°, SOIC / SOP +270°. Treat these as a first guess, especially on the bottom side.

In JLCPCB's placement preview, check:

- **Every IC:** the pin-1 dot on the part must sit on the pin-1 mark on the board (U7–U15, Q1).
- **One MT9105ET on the top:** the three legs must land on the three pads. Then all 46 match.
- **One SK6812MINI-E on the bottom:** the cut corner (pin 1, VDD) must match the board marking. LED18 and the other LEDs at 180° must match too.

If a part is wrong, rotate it in the preview. JLCPCB also reviews the placement before production and will email you if something looks off.

## Ordering

See [docs/BUILD.md → Ordering the main board from JLCPCB](../../../docs/BUILD.md#ordering-the-main-board-from-jlcpcb).
