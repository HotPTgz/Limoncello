# Verification status

What has been checked, how it was checked, and what still needs real hardware. Last updated November 2026.

## Checked

| What | How | Result |
|---|---|---|
| Main board DRC | KiCad 9/10 DRC with zones refilled (the builder's install) | 0 unconnected, 0 copper errors. 5 cosmetic silkscreen/fab warnings |
| Earlier DRC miss | KiCad 7 filled the zones differently and didn't flag 6 starved thermals on J2/J3 GND pins | Fixed: J2/J3 GND pins now connect solid to the pours. **Always run DRC in a current KiCad.** |
| Hall sensor pinout | MT9105ET datasheet (C967861): 1 VCC, 2 OUT, 3 GND; senses the field through the top (branded) face | Matches the footprint and all 46 sensors (3.3 V supply, output to mux) |
| Mux wiring | 74HC4051 pinout vs U10–U15 | S0–S2, COM, E̅ = GND, VEE = GND, VCC = 3.3 V all correct |
| LED wiring | SK6812MINI-E pinout (1 VDD, 2 DOUT, 3 GND, 4 DIN) | Correct. The chain runs through all 46 LEDs in one line |
| Level shifter, regulator, MOSFET, amp | 74AHCT1G125, AMS1117-3.3, 2N7002, PAM8403 pinouts vs board | Correct |
| Pi / Codec Zero headers | Pi 40-pin header (5 V, GND, I2C, I2S on GPIO 18–21, ID EEPROM, GPIO 22 mute) | Correct. GPIO 22 deliberately not passed to the Codec Zero |
| Firmware ↔ board | Script compares `firmware/src/config.h` + `keymap.h` with the KiCad nets | All pins match. All 46 keys have the right mux, channel and LED position |
| Firmware logic | Unit tests (`firmware/test`) on a PC, and `main.cpp` syntax-checked against stand-in Teensy headers | Pass |
| Printed parts | Every STL checked for closed (watertight) meshes; size vs a 220 × 220 mm bed (Creality K1) | All watertight. Largest part 178 × 192 mm, so it fits |
| Case vs parts | OpenSCAD/manifold clash checks against official Pi 5, cooler, Codec Zero and screen dimensions | No clashes |
| DAW | Unit tests and screenshots on a PC, sampling with a simulated mic | Pass |

## Not yet checked: needs your tools or the real hardware

1. **Firmware compile for Teensy.** PlatformIO couldn't download the Teensy toolchain here. Run `pio run` in `firmware/` once and fix anything it reports before flashing.
2. **The test board (4 keys).** It proves the sensor + magnet + footprint chain and the reading range. **Wait for it before ordering the main board.**
3. **JLCPCB placement preview.** The rotations in the CPL are a first guess. Check pin 1 of every IC, plus one sensor and one LED.
4. **1:1 printout.** Print `hardware/main-board/LMN_v3_revC_top.png` at 100 % and lay the Pi 5, Codec Zero and screen on it.
5. **Flush-key test print.** It picks the key gap (`GAP` in the case source).
6. **Codec Zero AUX OUT pads (J4).** Check L / GND / R on its silkscreen before soldering.
7. **Mic.** The electret capsule's GND leg is the one joined to its metal case. Also check the Codec Zero's mic socket gives the capsule bias, and test recording on the Pi (only tested with a simulated mic so far).
8. **DAW on the Pi.** Build and run the `lmn3-v3-wide` branch on the Pi 5 itself, at 1280 × 400.
9. **Regulator temperature.** The AMS1117 feeds 46 Hall sensors (about 0.28 A, 7 mA max each). It burns about 0.5 W and will run warm, which is within its rating. Touch-check it after 10 minutes.
