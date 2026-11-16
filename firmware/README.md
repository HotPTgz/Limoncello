# Limoncello Teensy 4.1 firmware

This is the firmware for the rev C board: Hall-effect keys, per-key RGB LEDs and the 7.9" screen layout.
- It sends exactly the same MIDI as the original LMN-3 firmware, so **LMN-3-DAW works unchanged**.
- The piano keys are now velocity-sensitive.

It is derived from FundamentalFrequency/LMN-3-Firmware and is licensed under GPL-3.0.

## Build and flash
1. Install VS Code with the PlatformIO extension. Alternatively, install PlatformIO Core: `pip install platformio`.
2. Open this folder and run **Upload** (from the command line: `pio run -t upload`).
   - Press the Teensy's button if the uploader asks you to.
3. Encoder, WS2812Serial and EEPROM come with the Teensy platform, so nothing else needs installing.

## What it does
| Part | Behaviour |
|---|---|
| Piano keys (24) | Note on at 70 % of travel, with velocity taken from how fast the key moves between 15 % and 70 %. Note off below 10 %. |
| Menu keys (22) | CC value 127 at 50 % of travel, CC value 0 below 30 %. The CC numbers are the same as the original. |
| Plus / Minus | Pressed alone, they send CC 118/119. With **Control** held, they shift the octave by ±1 on release (CC 117 = octave + 4, range ±4), as the original did. |
| Encoders | Relative CC 3/9/14/15 (1 = +1 step, 127 = −1 step). Push buttons send CC 20–23. |
| Joystick X | Pitch bend, now centred properly with a dead zone. |
| Joystick click | CC 114 (new); LMN-3-DAW uses it as sustain. With **Control** held, the click switches the joystick's up/down mod wheel on or off instead and sends CC 115 (127 = on, 0 = off) so the DAW can say so. The choice is remembered. Turn the click off entirely with `ENABLE_JOYSTICK_BUTTON` in `config.h`. |
| Joystick Y | Mod wheel CC 1, while switched on (see above). `ENABLE_MOD_WHEEL` in `config.h` is only the setting before you first switch it. |
| Mic key | CC 113 (new); in LMN-3-DAW it arms the mic, and Control + MIC samples. |
| LEDs | Each key group glows in its own colour. Keys light up when pressed (piano brightness follows velocity). The piano colour shows the current octave, and Plus/Minus turn yellow while Control is held. |

**New controls need the updated LMN-3-DAW** ([HotPTgz/lmn-3-daw, branch `lmn3-v3-wide`](https://github.com/HotPTgz/lmn-3-daw/tree/lmn3-v3-wide)) for CC 113, 114 and 115 to do something. Everything else works with any version.

## Calibration
The keys work out of the box: each key learns its full travel the first time you press it all the way down. Learned values are saved after 15 s without playing.

For a clean full calibration (recommended after assembly or after changing switches):
1. Hold **encoder 1's push button** while plugging in the USB cable, then let go. All the key LEDs turn red.
2. Press every key all the way down once. Each LED turns green when its key has been measured.
3. Press encoder 1 again. Three green flashes mean it has been saved.

The resting position of every key is measured at each power-up, so keep your hands off the keys while it boots. If a key is held during boot, it uses its saved rest value instead.

## Tuning (`src/config.h`)
- `VEL_FAST_US` / `VEL_SLOW_US` / `VEL_CURVE`: velocity feel. Lower `VEL_SLOW_US` makes soft playing louder.
- `VEL_HIGH`, `NOTE_OFF_POINT`, `MENU_PRESS`, `MENU_RELEASE`: actuation points, as per-mille of travel.
- `ENABLE_POLY_AFTERTOUCH`: polyphonic aftertouch from the last 15 % of travel.
- `LED_MAX_BRIGHTNESS`: hard cap on LED brightness (default 64 of 255). The LEDs run from the Pi's 5 V rail, so don't raise it much.

## Controlling the LEDs from the Pi (optional)
Send these MIDI messages to the Teensy on **channel 16**:
- Note On, note = key index 0–45 (SW1–SW46, see `src/keymap.h`), velocity = palette colour 1–15. A velocity of 0, or a Note Off, returns the key to its default colour.
- CC 7 sets brightness (0–127). CC 121 clears all colours.

Example from the Pi: `amidi -p hw:Teensy -S "9F 0C 01"` turns the Record key red.

## Debug
Open the Teensy serial monitor (works with the MIDI USB type) and type:
- `p`: raw value, rest, span and position of every key.
- `r`: scan rate.
- `s`: save calibration now.

The expected scan rate is several kHz.

## Tests
`test/test_engine.cpp` checks the key logic on a PC:

```
g++ -std=c++17 -Itest/mock -Isrc test/test_engine.cpp && ./a.out
```

It covers velocity, hysteresis, octave shift with held notes, reversed magnets and auto-ranging.
