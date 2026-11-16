# JLCPCB assembly files – main board rev C

These files let JLCPCB make the main board **and** solder the surface-mount parts.

| File | What it is |
|---|---|
| `LMN_v3_revC_gerbers.zip` | Gerbers and drill files, ready to upload first (same as the copy one folder up) |
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
| U10–U15 | 74HC4051D SOIC-16 | C9386 | E | Nexperia. Any 74HC4051 in narrow SOIC-16 fits, see below |
| SW1–SW46 | MT9105ET SOT-23 (top side) | C967861 | E | Hall sensors |
| LED1–LED46 | SK6812MINI-E (bottom side, reverse mount) | C5149201 | E | |

**Stock changes daily.** JLCPCB checks stock live when you upload the BOM. If a part shows as out of stock, pick an equivalent in the same package (same value, same or higher voltage), then update `make_jlcpcb.py`. The tightest lines are the MT9105ET (a few thousand in stock) and the Slkor PAM8403 (a few hundred to a few thousand). For one board you need 46 and 1 of them.

### If JLCPCB shows 0 stock for the LEDs (SK6812MINI-E, C5149201)

JLCPCB's assembly stock is separate from LCSC's, so the LEDs can show 0 at JLCPCB even when LCSC has tens of thousands. Two ways round it:

1. **Pre-order them into your JLCPCB parts library** (recommended).
   - Go to *Parts Manager → Order Parts*, search **C5149201**, and order at least 50. Pre-ordered parts have a minimum quantity, and assembly uses a few spares.
   - JLCPCB buys them from LCSC into your private library, which usually takes a few days.
   - Once they show in *My Parts Lib*, upload the BOM again: the LED line will now match your own stock.
2. **Leave the LEDs off and solder them yourself.** On the parts page, untick the LED line ("Do not place"), and order 50 × C5149201 from lcsc.com with the other hand-solder parts. Each LED drops into its hole from the bottom side, lens facing up through the board. That's 46 × 4 pads, slow but doable with a fine tip and flux.

Don't swap in a different LED (SK6812MINI-EA, -HS and so on) without checking its datasheet: the size and pinout must match the `SK6812MINI-E_MX_Reverse` footprint.

### If JLCPCB shows 0 stock for the muxes (74HC4051D,653, C9386)

The 4051 has the same pinout from every maker, so you can simply pick another one on JLCPCB's parts page. It must meet three conditions:

- **Plain 74HC4051, not 74HCT4051 or CD4051B.** The muxes run from **3.3 V** (`+3V3_HE`). The HCT version needs 4.5–5.5 V, and the CD4051B is specified from 3 V with much higher on-resistance.
- **Narrow SOIC-16 / SOP-16, 3.9 mm body, 1.27 mm pitch.** Not "208 mil", "7.4 mm" or TSSOP.
- **6 per board.**

Drop-in alternatives, in order of preference:

| Maker | Part | LCSC |
|---|---|---|
| Texas Instruments | CD74HC4051M96 | C132065 |
| Toshiba | 74HC4051D | C2673644 |
| Nexperia | 74HC4051D-Q100,118 (automotive grade, same chip) | C546997 |
| HGSEMI | 74HC4051M/TR | C507180 |

You can also pre-order C9386 itself into your parts library, the same way as the LEDs above.

## Rotations: check them

KiCad and JLCPCB use a different "zero" for some packages. The script adds the usual corrections: SOT-23 / SOT-23-5 / SOT-223 +180°, SOIC / SOP +270°. Treat these as a first guess, especially on the bottom side.

In JLCPCB's placement preview, check:

- **Every IC:** the pin-1 dot on the part must sit on the pin-1 mark on the board (U7–U15, Q1).
- **One MT9105ET on the top:** the three legs must land on the three pads. Then all 46 match.
- **One SK6812MINI-E on the bottom:** the cut corner (pin 1, VDD) must match the board marking. LED18 and the other LEDs at 180° must match too.

If a part is wrong, rotate it in the preview. JLCPCB also reviews the placement before production and will email you if something looks off.

## Ordering

See [docs/BUILD.md → Ordering the main board from JLCPCB](../../../docs/BUILD.md#ordering-the-main-board-from-jlcpcb).
