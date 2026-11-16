# Limoncello Hall-effect key test board

This is a 4-key test board that uses exactly the same key footprint as rev C:
- the MT9105ET Hall sensor under the switch;
- the SK6812MINI-E LED with its window and 100 nF capacitor;
- the same 74AHCT1G125 LED data buffer.

Use it to check that the sensor and Gateron magnetic switch combination works before you order the full 330 × 180 mm board.
The board is 87 × 42 mm, 2 layers. Design check (DRC): 0 errors, 0 unconnected.

## What's in here
| File | Use |
|---|---|
| `LMN_HE_test_gerbers.zip` | Upload to JLCPCB (2 layers, 1.6 mm, any colour). Five boards cost a few dollars. |
| `LMN_HE_test_BOM.csv`, `*_positions.csv` | Parts list (and placement file, if you want JLCPCB to assemble it). |
| `plate/test_plate.stl` (+ `.scad`) | 3D-printable switch plate: 1.5 mm plate on 3.5 mm legs, M2 screws. |
| `firmware/` | Test sketch for the Teensy 4.1 (PlatformIO or Arduino IDE). |
| `kicad/` | KiCad 7 project. |

## Parts to buy
- From LCSC:
  - about 10 × MT9105ET (spares are useful);
  - 5 × SK6812MINI-E;
  - 1 × 74AHCT1G125 (SOT-23-5);
  - 0805 parts: 5 × 100 nF, 1 × 1 µF, 1 × 330 Ω;
  - 1 × 10 µF 1206.
- 1 × 1×8 pin header (2.54 mm), 4 × M2×10 screws and nuts, jumper wires.
- 4 × Gateron Magnetic Jade switches. Use the same switch you plan to use for the full build.

## Assembly
1. **Top side:** solder the 4 Hall sensors. Keep them flat and centred on their pads, because that sets the distance to the magnet.
2. **Bottom side:**
   - Solder the LEDs. They sit in the windows, facing up through the board. The small triangle on the silkscreen marks pin 1.
   - Solder the capacitors, U1 and R1.
3. Solder the 1×8 header on the top side.
4. Screw the printed plate on, clip the 4 switches into the plate, and push them down until they sit flat on the board. HE switches have no metal pins: the plate is what holds them.

## Wiring to the Teensy 4.1
| Test board J1 | Teensy |
|---|---|
| 3V3 | 3.3V |
| GND | GND |
| 5V | VIN (USB 5 V) |
| LED | pin 17 |
| K1, K2, K3, K4 | pins 14, 15, 16, 18 |

These are the same pins the rev C board uses.

## Running the test
1. Flash `firmware/` with PlatformIO (`pio run -t upload`). Or open `LMN_HE_test/LMN_HE_test.ino` in the Arduino IDE with Teensyduino and set **Tools > USB Type: Serial + MIDI**.
2. Plug in the USB cable and **keep your hands off the keys for 2 seconds** while it measures the resting values. The LEDs go blue, then green.
3. Open the Serial Plotter to see the four readings live. Each LED goes from blue to red as you press its key.
4. Press every key all the way down a few times, both slowly and fast.
5. Type `r` in the serial monitor to get the report. It says **PASS** or **CHECK** for each key.
6. Optional:
   - Type `v`, then play: it shows the time between the two thresholds and the velocity of every note.
   - Open any synth or DAW on your computer: the keys play C, D, E and F with velocity.

## What the numbers mean
| Result | Meaning | What to do |
|---|---|---|
| **swing ≥ 200 counts, noise ≤ 10 p-p, keys within ±30 %** | Good: the sensor sees enough change and velocity will work well. | Order rev C as it is. |
| swing between 100 and 200 | It works, but the velocity resolution is coarse. | Still usable. Try a stronger-magnet switch, or lower `VEL_SLOW_US` in the main firmware's `config.h`. |
| swing < 100 | The sensor is too insensitive for this magnet, or a sensor sits crooked. | Re-check the soldering. If all keys are low, the sensor choice needs to change before ordering rev C. |
| noisy (> 10 p-p) | Supply or wiring noise. | Use short wires and twist GND with the signals. rev C has better grounding; the firmware can also average. |
| one key very different | Bad solder joint, tilted sensor, or a switch not seated flat. | Reflow that sensor or reseat the switch, then press `c` and test again. |

Keep the report (`r`) and a screenshot of the plotter: they tell you how to set the thresholds in `firmware/src/config.h` for your switches. If your results are unusual, please share them in an issue.

## Note for the full build
These switches need a **plate** (1.5 mm) to hold them, and the rev C board needs one too: it isn't in the shopping list or the board files yet.
