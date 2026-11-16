# Building a Limoncello

This guide goes from an empty desk to the first sound. Each step links to the detailed README of the part it uses.

**What you need to be comfortable with:**
- soldering through-hole parts and some 0805 / SOT-23 surface-mount parts (or let the PCB factory do the SMD parts);
- 3D printing about 1.2 kg of PLA/PETG on a 220 × 220 mm bed;
- the Raspberry Pi command line.

**Time:** a weekend for the electronics, plus about two days of printing.

> Limoncello is a prototype: nobody has built a complete one yet. Build the test board first (step 1). If something in this guide turns out wrong, please open an issue.

---

## 1. Try the keys on the test board (recommended)

The main board is big and costs about $80 to make. A 4-key test board with the same key circuit costs a few dollars and confirms that the Hall sensor, magnetic switch and LED work together.

- Files and instructions: [`hardware/test-board/`](../hardware/test-board).
- Order it from JLCPCB, solder it, flash the test sketch on a Teensy 4.1, and check that each key gives a smooth reading from rest to fully pressed and that the LEDs light.
- **Print the flush-key test piece too** ([`enclosure/flush_test/`](../enclosure/flush_test)). It sits on the test board and has four key openings, each with a different gap (0.35 / 0.45 / 0.55 / 0.65 mm). Play them and pick the gap with no rubbing and no wobble. Then set `GAP` in [`enclosure/source/lmn3_v3_case.scad`](../enclosure/source/lmn3_v3_case.scad) and re-export the keys and top shell (see step 6).

## 2. Order the parts and the board

- **Parts:** [SHOPPING_LIST.md](SHOPPING_LIST.md) (also as [CSV](shopping-list.csv)). The surface-mount parts come from LCSC. Most other parts are on Amazon or from the Pi and Teensy makers.
- **Main board:** upload [`hardware/main-board/LMN_v3_revC_gerbers.zip`](../hardware/main-board/LMN_v3_revC_gerbers.zip) to JLCPCB or PCBWay: 2 layers, 1.6 mm, 330 × 180 mm.
  - Optionally have JLCPCB solder the SMD parts: see [Ordering the main board from JLCPCB](#ordering-the-main-board-from-jlcpcb) below.
- **Before you order:** print [`LMN_v3_revC_top.png`](../hardware/main-board/LMN_v3_revC_top.png) at 1:1 and check your Pi 5, Codec Zero and screen against it.

## 3. Assemble the main board

Details: [`hardware/main-board/README.md`](../hardware/main-board/README.md).

1. **SMD parts** (if you didn't have them assembled).
   - **Top side:** the 46 MT9105ET Hall sensors. Keep them flat and centred, because their height sets the reading.
   - **Bottom side:**
     - the 46 SK6812MINI-E LEDs, facing up through their windows (the triangle marks pin 1);
     - the 6 × 74HC4051 muxes, the PAM8403 amp, the level shifter, the regulator, Q1 and the passives.
2. **Through-hole parts:** the Teensy 4.1 (on pin headers), J2 (the 2×20 **female** socket for the Pi, on the underside), J3 (the 2×20 **male** header for the Codec Zero, underside), the 4 encoders, the joystick, the headphone jack J5, the mic capsule MK1, and the JST-PH headers J4, J6, J7, J8.
3. **Cables** (table in the board README):
   - **J4:** 3 wires from the Codec Zero's AUX OUT pads. **Check L / GND / R on the Codec Zero's silkscreen before soldering.**
   - **J8:** to the Codec Zero's mic socket, through a 3.5 mm plug, using shielded wire.
   - **J6 / J7:** to the speakers. Never connect an amp output to GND.
4. **Switches:** screw the two printed plate halves on (step 6), clip the 46 switches through the plate, and press them flat onto the board.

## 4. Flash the Teensy

Details: [`firmware/README.md`](../firmware/README.md).

1. Install PlatformIO (VS Code extension, or `pip install platformio`).
2. In `firmware/`, run `pio run -t upload`.
3. **Calibrate:** hold encoder 1's button while plugging the USB in. All key LEDs turn red. Press every key all the way down once; each LED turns green. Then press encoder 1 to save.
4. Optional check on a computer: the Teensy shows up as a MIDI device. The keys send notes with velocity; the menu keys and encoders send CCs.

## 5. Raspberry Pi and software

Details: [SOFTWARE.md](SOFTWARE.md).

1. Install Raspberry Pi OS (64-bit, Desktop) on the microSD card.
2. Fit the **Active Cooler** on the Pi 5.
3. Screw a **6 mm M2.5 female-female stand-off** under each of the Pi's three free mounting holes, with M2.5 × 5 screws from the top. The fourth hole gets the **11 mm stand-off** to the board (H12).
4. Configure the Pi:
   - turn the screen to landscape and set the app size to 1280 × 400;
   - set up the Codec Zero;
   - for battery use, set the 5 A power setting.
5. Build the DAW from [HotPTgz/lmn-3-daw, branch `lmn3-v3-wide`](https://github.com/HotPTgz/lmn-3-daw/tree/lmn3-v3-wide) and make it start at boot.

## 6. Print the case

Details: [`enclosure/README.md`](../enclosure/README.md) (print settings for each part and the full hardware list).

- **Every part fits a 220 × 220 mm bed:**
  - the top shell, tray and switch plate come in two halves each, joined with 1.75 mm filament dowels and glue;
  - 22 labelled menu keys, 14 white and 10 black piano keys, 4 knobs;
  - a magnetic or a slide-on lid (or both);
  - the optional power bank cradle.
- **Materials:** use white or translucent filament for the keys, so the LEDs glow through. Use PETG for the switch plate and the cradle.
- **Changing something:** every dimension is a parameter in [`lmn3_v3_case.scad`](../enclosure/source/lmn3_v3_case.scad). Export a part with `openscad -D 'part="top_left"' -o top_left.stl lmn3_v3_case.scad`. The part names are listed at the top of the file.

## 7. Put it together

The order matters, because some screws are only reachable at certain stages.

1. Glue the two halves of the top shell and of the tray. Melt the 6 M3 heat-set inserts into the top shell's bosses (plus the 2 in the tray if you use the cradle). Glue the lid magnets.
2. Press the speakers into their rings under the grilles. Push the mic capsule into the seat at the bottom of the mic tube.
3. Plug the Pi (with the cooler and stand-offs) and the Codec Zero in under the board. Connect the cables:
   - Teensy to one of the Pi's **lower** USB ports;
   - the screen's USB-C (power) to the Pi;
   - the screen's HDMI (see [below](#the-screens-hdmi-cable)).
4. Stick 2–3 pads of 5 mm EVA foam on the board under the screen's centre block. Lay the screen on them, glass up, with its ports facing right.
5. Lower the top shell over the board: the screen drops into its pocket. Flip the whole thing over, put the tray on, and screw everything together from below:
   - 9 × M3 × 30 through the tray and the board;
   - 3 × M2.5 × 8 into the Pi's stand-offs.
6. Push the key tiles onto the switches through the top, then the knobs onto the encoders.

## 8. First sound

1. Power it with the **27 W (5.1 V 5 A)** supply into the rear USB-C.
2. The DAW starts on the Tracks screen.
3. Press **Plugins**, then **+**, and add **4OSC**. Play the keys: the speakers should sound, and the headphone jack mutes them.
4. [CONTROLS.md](CONTROLS.md) has every control. The original LMN-3 user guide covers the DAW's screens.

---

## The screen's HDMI cable

The Pi 5's micro-HDMI ports sit right at the rear wall of the case: they stick 1.6 mm past the Pi's edge. So a plug can only go in from **outside** the case, through the openings in the rear wall. The screen's HDMI port, though, is **inside**, under the right end of the screen. This route isn't finished yet. The two options are:

1. **A short flat cable that loops outside.** It plugs into the Pi from behind and comes back in through a slot in the rear wall near the screen. Simple, but not tidy.
2. **A micro-HDMI FPC ribbon kit with a 90° plug.** A small bump on the outside of the rear wall would house the plug head, so the ribbon can run up inside the case. Tidier, and it needs the matching connector on the screen end.

Until one of these is added to the case, you can use the cable that comes with the screen through the rear opening. Contributions are welcome.

## Running on battery

See [POWER.md](POWER.md):
- why the Pi 5 needs a 5 A supply;
- the UGREEN 20000 mAh bank and the 5 V 5 A converter;
- the printed cradle, which also tilts the instrument 8° towards you.

## Ordering the main board from JLCPCB

JLCPCB can make the board **and** solder all 173 SMD parts on both sides: the Hall sensors on top; the LEDs, muxes, amp, regulator and passives underneath. You then solder only the through-hole parts (step 3, item 2). Files and the part list: [`hardware/main-board/jlcpcb/`](../hardware/main-board/jlcpcb).

1. On jlcpcb.com, choose **Order now** and upload [`LMN_v3_revC_gerbers.zip`](../hardware/main-board/LMN_v3_revC_gerbers.zip). It should detect 2 layers and 330 × 180 mm. Keep 1.6 mm thickness and HASL lead-free (or ENIG). Pick any colour.
2. Turn on **PCB Assembly**:
   - **PCBA type: Standard.** Economic assembly only does one side, and this board has parts on both sides.
   - **Assembly side: Both sides.**
   - **Quantity:** as few as 2 boards; the minimum depends on what JLCPCB offers that day.
   - **Tooling holes:** let JLCPCB add them. The board has no fiducials, so let them add those too if the option is offered.
3. Upload the BOM `LMN_v3_revC_BOM_JLCPCB.csv` and the CPL `LMN_v3_revC_CPL_JLCPCB.csv`.
4. **Check the parts page.** Every line should show a matched part in stock. If a line is out of stock, choose an equivalent there, in the same package and with the same value. The folder README lists what matters for each part.
5. **Check the placement preview, part by part.** See "Rotations" in the [folder README](../hardware/main-board/jlcpcb/README.md):
   - every IC's pin 1 sits on the board's pin-1 mark;
   - one Hall sensor and one LED look right (then all 46 do);
   - flip to the bottom view for the bottom parts.
6. Place the order. JLCPCB's engineers review the placement and email you if anything needs confirming. Answer quickly, because the order waits until you do.

**Rough cost:** the 2-layer board and parts are cheap. Most of the price is the double-sided Standard assembly setup and the extended-part loading fees (about 9 lines), so the total depends mostly on those. This is an estimate, not a quote: expect something like $100–200 for 2 boards before shipping. The real quote updates live as you go.

**Not included, solder by hand:** Teensy 4.1 (on headers), J2 Pi socket, J3 Codec Zero header, the 4 encoders, the joystick, J5 jack, MK1 mic, and the JST-PH headers J4, J6, J7, J8. JLCPCB can also do through-hole assembly, but these parts are easy to hand-solder, and some (Teensy, joystick) are better bought separately.
