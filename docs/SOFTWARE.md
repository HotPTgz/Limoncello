# Software setup (Raspberry Pi 5)

Limoncello runs a fork of **LMN-3-DAW**: [HotPTgz/lmn-3-daw, branch `lmn3-v3-wide`](https://github.com/HotPTgz/lmn-3-daw/tree/lmn3-v3-wide). Compared with the original, it adds:
- a layout for wide screens (1280 × 400);
- the MIC key: record from the mic, and sample with Control + MIC;
- sustain on the joystick click;
- the built-in synths (String, FM, Pulse), the playful screens, the extra sequencers, and a keyboard/mouse mode for computers.

## 1. Raspberry Pi OS

1. Flash **Raspberry Pi OS (64-bit, with desktop)** with Raspberry Pi Imager. Set up Wi-Fi and SSH in the Imager's settings: it saves a lot of typing.
2. Boot the Pi. The first time, it's easiest with a normal monitor and keyboard, or over SSH.
3. Update: `sudo apt update && sudo apt full-upgrade -y`, then reboot.

## 2. The screen: landscape, 1280 × 400

The Waveshare 7.9" starts in portrait (400 × 1280).
- **From the desktop:** open **Screen Configuration** → right-click the screen → **Orientation** → *right* or *left*, whichever puts the picture the right way up → Apply.
- **From the command line (Wayland desktop):** run `wlr-randr` to see the output's name, then `wlr-randr --output HDMI-A-1 --transform 90`. Use `270` if it comes out upside down. To make it permanent, use Screen Configuration.

Then tell the DAW its size in `~/.config/LMN-3/config.yaml`:
```yaml
config:
  show-title-bar: false
  animations: true
  size:
    width: 1280
    height: 400
```
Any window more than 2.2 times as wide as it is tall gets the wide layout.

## 3. Audio: Codec Zero

1. The Codec Zero is usually detected on its own (HAT EEPROM). If it isn't, add `dtoverlay=rpi-codeczero` to `/boot/firmware/config.txt` (older images: `dtoverlay=iqaudio-codec`). Comment out `dtparam=audio=on`, then reboot.
2. Load a mixer setup from Raspberry Pi's [Pi-Codec](https://github.com/raspberrypi/Pi-Codec) repository: the *external mic record + AUX OUT playback* state. Then run `sudo alsactl store`.
3. The speaker level is the codec's **Headphone** volume, because the amp's gain is fixed (about +9 dB). Start low.
4. In the DAW's **Settings**, pick the Codec Zero ("Zero") as the output device. MIC opens its input when you first use it.

## 4. Power settings

With the official 27 W supply, nothing is needed. With a power bank through a 5 V 5 A converter (see [POWER.md](POWER.md)), tell the Pi once that it has 5 A:
```
sudo rpi-eeprom-config --edit      # add the line PSU_MAX_CURRENT=5000, save
sudo reboot
```
Only do this when the supply really gives 5 A.

## 5. Build the DAW

Building on the Pi takes a while (about an hour on a Pi 5) and needs at least 4 GB of RAM.
```bash
sudo apt install -y libasound2-dev libjack-jackd2-dev ladspa-sdk libcurl4-openssl-dev libfreetype6-dev \
  libx11-dev libxcomposite-dev libxcursor-dev libxext-dev libxinerama-dev libxrandr-dev libxrender-dev \
  libglu1-mesa-dev mesa-common-dev build-essential cmake clang llvm lld git
git clone --recurse-submodules -b lmn3-v3-wide https://github.com/HotPTgz/lmn-3-daw ~/LMN-3-DAW
cd ~/LMN-3-DAW
cmake -B build -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-fuse-ld=lld
cmake --build build -j4 --target LMN-3
```
The app ends up at `~/LMN-3-DAW/build/LMN-3_artefacts/Release/LMN-3`.

Optionally run the tests: `cmake --build build -j4 --target Tests && ./build/Tests/Tests_artefacts/Release/Tests`.

## 6. Start it at boot, full screen

On the current desktop (labwc), make your own copy of the autostart file and add the app:
```bash
mkdir -p ~/.config/labwc
cp /etc/xdg/labwc/autostart ~/.config/labwc/autostart
sed -i 's/^\(.*wf-panel-pi.*\)$/# \1/' ~/.config/labwc/autostart     # hide the taskbar
echo '/home/'"$USER"'/LMN-3-DAW/build/LMN-3_artefacts/Release/LMN-3 &' >> ~/.config/labwc/autostart
```
Reboot. To undo it, delete `~/.config/labwc/autostart`.

## 7. Samples and drum kits

- Put synth samples in `~/.config/LMN-3/samples`. Sounds sampled with Control + MIC land in `samples/Recorded`.
- Drum kits go in `~/.config/LMN-3/drum_kits`: one `.yaml` map per kit plus a folder of the same name with its samples. The map has `name:` and a `mappings:` list of `note_number` / `file_name`. The pads are notes 53–76.
- The fork's README has the details.

## Updating

```bash
cd ~/LMN-3-DAW && git pull && git submodule update --init --recursive
cmake --build build -j4 --target LMN-3
```

## Firmware (Teensy)

See [`firmware/README.md`](../firmware/README.md). You can flash it from the Pi itself with PlatformIO (`pip install platformio`, then `pio run -t upload` in `firmware/`). Keep your hands off the keys while it boots: each key measures its resting position at power-up.
