// LMN-3 v3 (rev C) firmware configuration.
// Based on the original LMN-3 firmware (FundamentalFrequency/LMN-3-Firmware, GPL-3.0).
#pragma once
#include <Arduino.h>

// ---------------------------------------------------------------- MIDI
// CC numbers are identical to the original firmware so LMN-3-DAW works unchanged.
const uint8_t MIDI_CH = 1;
const uint8_t ENCODER_1 = 3, ENCODER_2 = 9, ENCODER_3 = 14, ENCODER_4 = 15;
const uint8_t ENCODER_1_BUTTON = 20, ENCODER_2_BUTTON = 21, ENCODER_3_BUTTON = 22, ENCODER_4_BUTTON = 23;
const uint8_t UNDO_BUTTON = 24, TEMPO_BUTTON = 25, SAVE_BUTTON = 26;
const uint8_t SETTINGS_BUTTON = 85, TRACKS_BUTTON = 86, MIXER_BUTTON = 88, PLUGINS_BUTTON = 89;
const uint8_t MODIFIERS_BUTTON = 90, SEQUENCERS_BUTTON = 102;
const uint8_t LOOP_IN_BUTTON = 103, LOOP_OUT_BUTTON = 104, LOOP_BUTTON = 105;
const uint8_t CUT_BUTTON = 106, PASTE_BUTTON = 107, SLICE_BUTTON = 108;
const uint8_t RECORD_BUTTON = 109, PLAY_BUTTON = 110, STOP_BUTTON = 111, CONTROL_BUTTON = 112;
const uint8_t OCTAVE_CHANGE = 117, PLUS_BUTTON = 118, MINUS_BUTTON = 119;
// New on rev C (need a mapping in LMN-3-DAW to do something):
const uint8_t MIC_BUTTON = 113;        // the new "mic" key
const uint8_t JOYSTICK_BUTTON = 114;   // joystick click
const uint8_t MOD_WHEEL = 1;           // joystick Y axis (if switched on)
const uint8_t MOD_WHEEL_STATE = 115;   // sent when Control + joystick click switches the mod wheel (127 on, 0 off)
const uint8_t VELOCITY_STATE = 116;    // sent when Control + Tempo switches key velocity (127 on, 0 off = fixed velocity)

// ---------------------------------------------------------------- pins (rev C PCB)
const uint8_t PIN_MUX_S0 = 0, PIN_MUX_S1 = 1, PIN_MUX_S2 = 2;
const uint8_t PIN_MUX_COM[6] = {14, 15, 16, 18, 19, 20};   // A0 A1 A2 A4 A5 A6
const uint8_t PIN_LED_DATA = 17;                           // -> 74AHCT1G125 -> LED chain
const uint8_t PIN_ENC[4][2] = {{5, 6}, {26, 27}, {29, 30}, {31, 32}};
const uint8_t PIN_ENC_SW[4] = {9, 10, 11, 12};
const uint8_t PIN_JOY_X = 39, PIN_JOY_Y = 38, PIN_JOY_SEL = 37;

// ---------------------------------------------------------------- Hall-effect keys
// Key travel is normalised to 0..1000 (per-mille of the calibrated span).
const uint16_t DEFAULT_SPAN   = 300;   // ADC counts (12 bit) rest->bottom before calibration; grows automatically
const uint16_t MIN_SPAN       = 80;
const uint8_t  MUX_SETTLE_US  = 3;
// menu keys
const int16_t MENU_PRESS      = 500;   // actuation point
const int16_t MENU_RELEASE    = 300;
// piano keys: velocity = time between crossing VEL_LOW and VEL_HIGH
const int16_t VEL_LOW         = 150;
const int16_t VEL_HIGH        = 700;   // note-on point
const int16_t NOTE_OFF_POINT  = 100;
const uint32_t VEL_FAST_US    = 3000;  // <= this -> velocity 127
const uint32_t VEL_SLOW_US    = 60000; // >= this -> velocity 1
const float    VEL_CURVE      = 1.4f;  // >1 = need to play harder for loud notes
const bool     ENABLE_VELOCITY = true;  // the default; Control + Tempo switches it (remembered)
const uint8_t  FIXED_VELOCITY  = 100;   // what every note gets while velocity is off
const bool     ENABLE_POLY_AFTERTOUCH = false;   // pressure from the last part of the travel
const int16_t  AFTERTOUCH_START = 850;

// ---------------------------------------------------------------- joystick
const bool    JOY_X_INVERT = true;     // original firmware: right = higher pitch with this board orientation
const int16_t JOY_DEADZONE = 40;       // ADC counts around centre
const bool    ENABLE_MOD_WHEEL = false; // the default; Control + joystick click switches it (remembered)
const bool    ENABLE_JOYSTICK_BUTTON = true;

// ---------------------------------------------------------------- octave
const int8_t MAX_TRANSPOSITION = 4;    // +-4 octaves, as the original

// ---------------------------------------------------------------- LEDs (SK6812MINI-E, GRB)
// 46 LEDs at full white can draw ~2.7 A from the Pi's 5 V rail; keep this low.
const uint8_t LED_MAX_BRIGHTNESS = 64; // 0..255 hard cap (~25 %)
const uint8_t LED_IDLE_LEVEL     = 40; // 0..255, base glow relative to full
const uint16_t LED_FADE_MS       = 350;
const uint8_t HOST_LED_CHANNEL   = 16; // Pi -> Teensy LED control (see README)
