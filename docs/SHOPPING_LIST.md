# Shopping list

Prices are rough estimates in USD (November 2026). Check them before ordering. The same list is in [`shopping-list.csv`](shopping-list.csv) for spreadsheets.

- **Core parts** (everything except the SMD parts and the battery): about **$522**
  - plus **$200** if JLCPCB assembles the SMD parts, **or** about **$33** of SMD parts to solder yourself
- **Battery option**: about **$93**

Reuse what you already have: a Pi 5, a Teensy 4.1, the encoders and the joystick from an original LMN-3 all work.

| Item | Qty | Est. each | Category | Where | Notes |
|---|---|---|---|---|---|
| Raspberry Pi 5 (8 GB) | 1 | $80.00 | Computer | [Amazon](https://www.amazon.com/s?k=Raspberry+Pi+5+8GB) | 4 GB also works, but building the software on the Pi needs at least 4 GB. |
| Raspberry Pi 5 Active Cooler (official) | 1 | $6.00 | Computer | [Amazon](https://www.amazon.com/s?k=Raspberry+Pi+5+Active+Cooler+official) | The board has an opening shaped around this exact cooler. |
| Raspberry Pi 27W USB-C power supply (5.1 V 5 A) | 1 | $13.00 | Power | [Amazon](https://www.amazon.com/s?k=Raspberry+Pi+27W+USB-C+power+supply+official) | The Pi, LEDs, amp and Teensy all run from the Pi's 5 V, so it needs the 5 A supply. |
| microSD card 64 GB, A2 | 1 | $10.00 | Computer | [Amazon](https://www.amazon.com/s?k=SanDisk+Extreme+64GB+microSD+A2) |  |
| Teensy 4.1 (with pins) | 1 | $32.00 | Computer | [PJRC](https://www.pjrc.com/store/teensy41.html) | PJRC or SparkFun are cheapest. |
| Waveshare 7.9inch Side Monitor (non-touch, 400 x 1280) | 1 | $80.00 | Display | [Amazon](https://www.amazon.com/s?k=Waveshare+7.9inch+Side+Monitor+400x1280) | The metal-cased monitor. Comes with an HDMI flat cable, a micro-HDMI adapter and a USB-C cable. |
| Raspberry Pi Codec Zero | 1 | $27.00 | Audio | [PiShop](https://www.pishop.us/product/raspberry-pi-codec-zero/) | Audio in/out. Rarely on Amazon at list price. |
| Speaker, 40 mm, 4 ohm, 3 W (Adafruit 3968) | 2 | $4.95 | Audio | [Adafruit](https://www.adafruit.com/product/3968) | 40 mm round, 20 mm tall: press-fits the rings under the grilles. Any round 40 mm 4-8 ohm speaker without mounting ears also fits. |
| 6 mm electret mic capsule (10-pack) | 1 | $6.00 | Audio | [Amazon](https://www.amazon.com/s?k=6mm+electret+microphone+capsule) | One goes in MK1; the rest are spares. |
| 3.5 mm mono/TRS plug, solderable or pigtail | 2 | $4.00 | Audio | [Amazon](https://www.amazon.com/s?k=3.5mm+male+plug+solder+type) | Mic cable from J8 to the Codec Zero's mic socket. Use shielded wire. |
| CUI SJ1-3535NG switched 3.5 mm jack | 1 | $1.60 | Audio | [LCSC](https://www.lcsc.com/search?q=SJ1-3535NG) | J5, the headphone jack. The footprint is for this exact part. |
| Gateron Magnetic Jade Hall-effect switches (10-pack) | 5 | $8.00 | Keys | [Amazon](https://www.amazon.com/s?k=Gateron+Magnetic+Jade+hall+effect+switches) | 46 needed + spares. Mechanical switches don't work on this board. |
| EC11 rotary encoder, 20 mm knurled shaft, with push (5-pack) | 1 | $10.00 | Controls | [Amazon](https://www.amazon.com/s?k=EC11+rotary+encoder+20mm+knurled+shaft+push+button) | 4 needed. The knobs are printed. |
| SparkFun thumb joystick COM-09032 (with breakout) | 1 | $5.00 | Controls | [SparkFun](https://www.sparkfun.com/thumb-joystick.html) | Same part as the original LMN-3. |
| JST-PH 2.0 kit (2/3-pin housings, vertical headers, pre-crimped wires) | 1 | $13.00 | Wiring | [Amazon](https://www.amazon.com/s?k=JST+PH+2.0+connector+kit+pre-crimped) | J4, J6, J7, J8 and the cables to the Codec Zero, speakers and mic. |
| 2x20 female header 2.54 mm (8.5 mm tall) + 2x20 male header | 1 | $8.00 | Wiring | [Amazon](https://www.amazon.com/s?k=2x20+pin+female+header+2.54mm+raspberry+pi) | J2: socket for the Pi. J3: male header for the Codec Zero. |
| Short right-angle micro-USB to USB-A cable (15-20 cm) | 1 | $8.00 | Wiring | [Amazon](https://www.amazon.com/s?k=short+right+angle+micro+USB+to+USB+A+cable+20cm) | Teensy to Pi (MIDI). Use one of the Pi's lower USB ports. |
| Screen HDMI cable (see the open point in BUILD.md) | 1 | $12.00 | Wiring | [Amazon](https://www.amazon.com/s?k=micro+HDMI+90+degree+FPC+ribbon+cable+kit) | Route still to be decided: a short flat cable looping outside, or a micro-HDMI FPC kit. |
| M2.5 brass stand-off + screw kit | 1 | $12.00 | Hardware | [Amazon](https://www.amazon.com/s?k=M2.5+brass+standoff+screw+kit) | Pi mounting: 1 x 11 mm F-F (H12), 3 x 6 mm F-F under the Pi, M2.5 x 5 and x 8 screws. |
| M3 heat-set inserts (M3 x 5.7) + M3 screw kit | 1 | $14.00 | Hardware | [Amazon](https://www.amazon.com/s?k=M3+heat+set+insert+kit+screws) | 6 inserts in the top shell (+2 for the cradle). 9 x M3 x 30 screws (+2 x M3 x 10 for the cradle). |
| Neodymium disc magnets 8 x 3 mm | 16 | $0.30 | Hardware | [Amazon](https://www.amazon.com/s?k=8x3mm+neodymium+magnets) | Magnetic lid only. |
| Rubber feet, 10 mm round, self-adhesive | 8 | $0.40 | Hardware | [Amazon](https://www.amazon.com/s?k=10mm+rubber+feet+self+adhesive) | 4 for the case, 4 for the power bank cradle. |
| EVA foam sheet, 5 mm | 1 | $5.00 | Hardware | [Amazon](https://www.amazon.com/s?k=5mm+EVA+foam+sheet+adhesive) | 2-3 small pads under the screen. |
| PLA or PETG filament, white or translucent, 1 kg | 1 | $18.00 | Printing | [Amazon](https://www.amazon.com/s?k=PETG+filament+translucent+1kg) | Shell, tray, menu keys and white keys. Translucent lets the key LEDs glow through. |
| PLA filament, black, 1 kg | 1 | $16.00 | Printing | [Amazon](https://www.amazon.com/s?k=PLA+filament+black+1kg+1.75mm) | Black keys and knobs. |
| PCB fabrication, 330 x 180 mm, 2-layer, qty 5 | 1 | $80.00 | PCB | [JLCPCB](https://jlcpcb.com) | Upload hardware/main-board/LMN_v3_revC_gerbers.zip. A large board, so check the quote. |
| PCB assembly of the SMD parts (optional) | 1 | $200.00 | PCB | [JLCPCB](https://jlcpcb.com) | Rough guess. Parts on both sides. If you choose this, skip the SMD rows below. |
| MT9105ET Hall sensor, SOT-23 | 50 | $0.25 | SMD parts | [LCSC](https://www.lcsc.com/search?q=MT9105ET) | One per key (46) + spares. |
| SK6812MINI-E reverse-mount RGB LED | 50 | $0.15 | SMD parts | [LCSC](https://www.lcsc.com/search?q=SK6812MINI-E) | One per key (46) + spares. |
| 74HC4051 analog mux, SOIC-16 | 8 | $0.20 | SMD parts | [LCSC](https://www.lcsc.com/search?q=74HC4051D) | 6 needed. |
| PAM8403 stereo class-D amp, SOP-16 | 2 | $0.30 | SMD parts | [LCSC](https://www.lcsc.com/search?q=PAM8403DR) | U9. |
| 74AHCT1G125 level shifter, SOT-23-5 | 2 | $0.15 | SMD parts | [LCSC](https://www.lcsc.com/search?q=74AHCT1G125) | U7, LED data. |
| AMS1117-3.3 regulator, SOT-223 | 2 | $0.15 | SMD parts | [LCSC](https://www.lcsc.com/search?q=AMS1117-3.3) | U8, sensor supply. |
| 2N7002 MOSFET, SOT-23 | 5 | $0.03 | SMD parts | [LCSC](https://www.lcsc.com/search?q=2N7002) | Q1, speaker mute. |
| Capacitors: 100nF 0805 x60, 22uF 1206 x8, 1uF 0805 x5, 0.47uF 0805 x4 | 1 | $8.00 | SMD parts | [LCSC](https://www.lcsc.com) | See the BOM for references. |
| Resistors 0805: 330R, 82k x2, 100k x3, 10k | 1 | $2.00 | SMD parts | [LCSC](https://www.lcsc.com) | Sold in strips of 100. |
| UGREEN Nexode Power Bank 20000mAh 130W | 1 | $57.00 | Battery (optional) | [UGREEN](https://us.ugreen.com/pages/ugreen-nexode-power-bank) | Fits the printed cradle. About 4.5-5 h of playing. |
| USB-PD to 5.1 V 5 A converter board for Pi 5 | 1 | $20.00 | Battery (optional) | [Tindie](https://www.tindie.com/products/regaldreamtech/usb-pd-2030-to-5v-5a-converter-board-for-rpi5) | Any board up to 64 x 46 mm fits the cradle's bay (e.g. RegalDream RDv5, or the 59 x 44 mm Pi 5 PD modules). |
| USB-C to USB-C cable, 10-15 cm | 1 | $6.00 | Battery (optional) | [Amazon](https://www.amazon.com/s?k=short+USB+C+to+USB+C+cable+15cm) | Bank to converter. |
| Right-angle USB-C cable, 25-30 cm, 5 A (e-marked) | 1 | $10.00 | Battery (optional) | [Amazon](https://www.amazon.com/s?k=right+angle+USB+C+cable+5A+30cm) | Converter to the Limoncello's USB-C. |
