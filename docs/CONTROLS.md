# Controls

Limoncello keeps all of the LMN-3's controls and adds a few. The DAW's screens are the LMN-3's, explained in its user guide. The knob boxes on the right of the screen always say what each encoder does right now. They sit in the same 2 × 2 order as the encoders next to the screen:

```
 [1] [2]
 [3] [4]
```

## The panel

| Control | What it does |
|---|---|
| Piano keys (24) | Play the selected track, with **velocity**: the built-in synths (String, FM, Pulse) go from soft to loud over 30 dB; 4OSC is −20 dB at half velocity and almost silent at the softest (its **Amp Velocity** knob narrows that); the sampler spans 20 dB. On some screens they also pick things: drum pads, step notes, chord roots |
| Octave (Control + Plus / Minus) | Shift the keys ±4 octaves; the piano keys' LED colour shows the octave |
| Encoders 1–4 | Turn and press. What they do is shown in the four boxes |
| Control (hold) | Second layer of every encoder; combines with other keys |
| Tracks, Plugins, Modifiers, Sequencers, Mixer, Tempo, Settings | Jump to that screen |
| Plus / Minus | Add / remove (tracks, plugins…); next / previous page on plugin screens |
| Play, Stop, Record | Transport. Record gives a one-bar count-in |
| Loop In, Loop Out, Loop | Loop points at the playhead; loop on/off |
| Cut, Paste, Slice, Undo | Edit clips at the playhead |
| Save / Control + Save | Save / render |
| Control + Stop (hold 3 s) | Save and power off safely |

## New on Limoncello

| Control | What it does |
|---|---|
| **Joystick left/right** | Pitch bend (as on the LMN-3) |
| **Joystick click** | **Sustain** while held, like a sustain pedal: 4OSC, String, FM, Pulse |
| **Control + joystick click** | Switches joystick **up/down** as the **mod wheel** on or off. The Teensy remembers it, and the screen says which |
| **Control + Tempo** | Switches **key velocity** on or off. Off: every note plays at the same velocity (100), however hard you press. The Teensy remembers it, and the screen says which |
| **MIC** | **Arms the built-in mic** on the selected track: the next **Record** records sound from it. MIC again turns it off. The Tracks header shows `mic → n`. The mic is never played through the speakers, so it can't howl |
| **Control + MIC** | **Sample**: make a sound, press MIC again (or wait 20 s). The silence around it is trimmed and the level evened out. Then: |
| | - a **drum sampler** on the track: play the key for the pad it goes on |
| | - a **sampler**: it plays across the keys |
| | - a track with **no instrument**: a new sampler is added with it |
| | It's always saved in `samples/Recorded` too |
| **Headphone jack** | Plugging in headphones mutes the speakers (in hardware) |

## Keys and LEDs

- Each key's LED glows in its group's colour and lights up when pressed. A piano key's brightness follows how hard you played it.
- **Calibration:** hold encoder 1 while plugging in → press every key fully once (red → green) → press encoder 1 to save.

## On a computer

Run the DAW with `LMN3_KEYBOARD=1` and press F12 for the cheat sheet. F9 is MIC and F10 the joystick click.
