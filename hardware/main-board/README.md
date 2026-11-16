# Limoncello main board (rev C): Hall-effect keys, RGB, 7.9" bar screen, Codec Zero audio

Board: 330 × 180 mm, 2 layers, 1.6 mm, GND pour on both layers.
DRC: 0 clearance errors, 0 unconnected. The only warnings left are silkscreen and library-path notices.

**Pi cooler opening (sized from the official Raspberry Pi drawings):** the rear edge is open over the Pi. Dimensions are measured from the board's left and rear edges.
- **Sources:** the Pi 5 STEP model and the Active Cooler mechanical drawing from Raspberry Pi.
- **Why it's needed:** the cooler stands about 10.5 mm above the Pi's top face. The gap between the Pi and this board (header plastic + socket) is 11 mm, so the cooler and its push pins need room above it.
- **Shape:** the opening runs x 107.5–197.3 mm, in three depth steps:
  - x 107.5–130.5: 56.5 mm deep, for the USB/Ethernet stack, which overhangs the Pi by 3 mm.
  - x 130.5–190.5: 50.3 mm deep, over the cooler body and fins.
  - x 190.5–197.3: 14.5 mm deep. The cooler corner here is empty, which leaves a routing corridor next to the GPIO header.
- **USB:** only the **lower** two USB ports and Ethernet are reachable. The board edge covers the upper USB pair.
- **Cables:** the opening also passes the HDMI and USB-C cables.
- **Mounting:** the cooler uses the Pi's two dedicated heatsink holes. The Pi is held by the GPIO header, **one M2.5 stand-off (H12)**, and three posts in the bottom tray under its other mounting holes. H11 was removed to make room for routing.
- **Routing:** the Pi → Codec Zero connections were re-routed around the opening.
  - Pin 17 (the second 3.3 V pin) is left unconnected on both J2 and J3. The Pi and the Codec Zero each tie it to pin 1 on their own board, so J2.1 → J3.1 feeds 3.3 V.
  - GPIO23/24/27 (the Codec Zero's LEDs and button) are no longer wired: they would be hidden inside the case anyway.

## What's on the board
- 46 Hall-effect keys (MT9105ET, per switch), 46 SK6812MINI-E LEDs, 6 × 74HC4051 → Teensy 4.1 (same as rev B, new layout).
- J2: underside socket for the Raspberry Pi 5 (held by the header, 1 M2.5 stand-off (H12) and 3 tray posts).
- **Audio**:
  - **J3:** a 2×20 male header wired in parallel with J2. The **Raspberry Pi Codec Zero** plugs onto it from below.
    - Its 40-pin female header goes onto J3, with its component side facing the case floor.
    - Its outline is drawn on Cmts.User/B.Fab.
  - **U9:** a PAM8403 stereo class-D amp, fed from the Codec Zero's Headphone/AUX OUT. It drives the two side speakers.
  - **J5:** a switched 3.5 mm headphone jack (CUI SJ1-3535NG) on the right edge. Plugging in headphones disconnects the amp input, so the speakers go silent. No software is involved.
  - **MK1:** a 6 mm electret capsule under the mic pinhole in front of the screen. J8 runs it to the Codec Zero's external-mic 3.5 mm socket.
    - Plugging into that socket disables the Codec Zero's built-in MEMS mic automatically.
  - **Q1 (2N7002):** lets GPIO22 mute the speakers. GPIO22 low or floating = amp on (default); GPIO22 high = mute.
  - **Other pins wired through to J3:** ID_SD/ID_SC (HAT EEPROM auto-config).

## Cables you make
| From | To | Notes |
|---|---|---|
| Codec Zero **P2 (AUX OUT)** pads | **J4** (JST-PH 3-pin: 1 = L, 2 = GND, 3 = R) | Solder 3 wires to P2. **Check L/GND/R on the Codec Zero silkscreen** (pin 1 is the square pad). |
| **J8** (JST-PH 2-pin: 1 = mic +, 2 = GND) | Codec Zero mic socket | Mono 3.5 mm plug: tip = mic +, sleeve = GND. Shielded cable. |
| **J6 / J7** (JST-PH 2-pin) | Left / right speaker | 40 mm, 4–8 Ω, 2–3 W. Twist each pair. Never connect either output terminal to GND (bridged outputs). |

## Software (Raspberry Pi OS)
1. With J3 wired to the HAT EEPROM, the Codec Zero is usually detected automatically. If it isn't, add `dtoverlay=rpi-codeczero` to `/boot/firmware/config.txt` (older images use `dtoverlay=iqaudio-codec`). Also comment out `dtparam=audio=on`.
2. Load a mixer preset from Raspberry Pi's **Pi-Codec** repository (github.com/raspberrypi/Pi-Codec). Use the external-mic record + AUX OUT playback state, then `sudo alsactl store`.
3. The speaker level is set by the codec's **Headphone** volume, because the amp gain is fixed by R2/R3 (82 kΩ ≈ +9 dB). Start low.
4. In LMN-3-DAW (Tracktion), select the "Zero" card as both the input and the output device.

## Power notes
Everything is fed from the Pi's 5 V rail (pins 2/4), so use the official 27 W (5 V 5 A) USB-C supply.
- The 46 LEDs can draw up to about 2.7 A at full white.
- Cap brightness in the Teensy firmware (about 25% is plenty).
- The amp draws up to about 1 A on loud peaks.

## Files
- `gerbers/` + `*_gerbers.zip`: upload the zip to JLCPCB/PCBWay.
- `jlcpcb/`: BOM and placement (CPL) files in JLCPCB format, with LCSC part numbers, for having the SMD parts assembled. See its README.
- `*_BOM.csv`, `*_positions.csv`: BOM and pick-and-place (most SMD parts are on the bottom side).
- `*.step`: 3D model of the board.
- `kicad/`: KiCad 7 project with the custom footprints.
- `LMN_v3_mux_map.csv`, `LMN_v3_keys.json`: key ↔ mux channel ↔ Teensy pin map (needed for the firmware).

## Before you order
- Print the board 1:1 on paper. Check the Codec Zero, Pi 5 and screen positions against the real parts.
- Check that the Codec Zero (on J3, plus its female header) clears the case floor. It needs about 20 mm below the PCB.
