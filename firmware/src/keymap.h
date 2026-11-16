// Key table for the rev C PCB, generated from the KiCad board (LMN_v3_mux_map.csv + LED chain order).
// Order = switch reference SW1..SW46.
#pragma once
#include "config.h"

enum KeyType : uint8_t { MENU, PIANO };
enum Group : uint8_t { G_LOOP, G_EDIT, G_FILE, G_PLUSMINUS, G_CONTROL, G_REC, G_PLAY, G_STOP, G_MIC, G_VIEW, G_WHITE, G_BLACK };

struct KeyDef {
    uint8_t mux, ch;     // 74HC4051 (0..5 = U10..U15) and channel (= select code)
    KeyType type;
    uint8_t id;          // CC number (MENU) or MIDI note at transposition 0 (PIANO)
    uint8_t led;         // position in the LED chain (0 = first after the level shifter)
    Group group;
};

const uint8_t NUM_KEYS = 46;
const KeyDef KEYS[NUM_KEYS] = {
    // row C (top menu row), left to right
    {0, 0, MENU, LOOP_BUTTON,     0, G_LOOP},       // SW1  Loop
    {0, 1, MENU, LOOP_IN_BUTTON,  1, G_LOOP},       // SW2  Loop in
    {1, 0, MENU, LOOP_OUT_BUTTON, 2, G_LOOP},       // SW3  Loop out
    {1, 1, MENU, CUT_BUTTON,      3, G_EDIT},       // SW4  Cut
    {1, 2, MENU, PASTE_BUTTON,    4, G_EDIT},       // SW5  Paste
    {2, 0, MENU, SLICE_BUTTON,    5, G_EDIT},       // SW6  Slice
    {2, 1, MENU, SAVE_BUTTON,     6, G_FILE},       // SW7  Save
    {3, 0, MENU, UNDO_BUTTON,     7, G_FILE},       // SW8  Undo
    {3, 1, MENU, TEMPO_BUTTON,    8, G_FILE},       // SW9  Tempo
    {4, 0, MENU, MINUS_BUTTON,    9, G_PLUSMINUS},  // SW10 Minus / octave down (with Control)
    {4, 1, MENU, PLUS_BUTTON,    10, G_PLUSMINUS},  // SW11 Plus  / octave up   (with Control)
    // row D (second menu row), left to right
    {0, 2, MENU, CONTROL_BUTTON,   21, G_CONTROL},  // SW12 Control (shift)
    {0, 3, MENU, RECORD_BUTTON,    20, G_REC},      // SW13 Record
    {1, 3, MENU, PLAY_BUTTON,      19, G_PLAY},     // SW14 Play
    {1, 4, MENU, STOP_BUTTON,      18, G_STOP},     // SW15 Stop
    {2, 2, MENU, MIC_BUTTON,       17, G_MIC},      // SW16 Mic input (new)
    {2, 3, MENU, SETTINGS_BUTTON,  16, G_VIEW},     // SW17 Settings
    {3, 2, MENU, MIXER_BUTTON,     15, G_VIEW},     // SW18 Mixer
    {3, 3, MENU, TRACKS_BUTTON,    14, G_VIEW},     // SW19 Tracks
    {3, 4, MENU, PLUGINS_BUTTON,   13, G_VIEW},     // SW20 Plugins
    {4, 2, MENU, MODIFIERS_BUTTON, 12, G_VIEW},     // SW21 Modifiers
    {4, 3, MENU, SEQUENCERS_BUTTON,11, G_VIEW},     // SW22 Sequencers
    // row E: black keys, left to right (F# G# A# C# D# F# G# A# C# D#)
    {0, 4, PIANO, 54, 22, G_BLACK}, {0, 5, PIANO, 56, 23, G_BLACK}, {1, 5, PIANO, 58, 24, G_BLACK},
    {2, 4, PIANO, 61, 25, G_BLACK}, {2, 5, PIANO, 63, 26, G_BLACK}, {3, 5, PIANO, 66, 27, G_BLACK},
    {4, 4, PIANO, 68, 28, G_BLACK}, {4, 5, PIANO, 70, 29, G_BLACK}, {5, 0, PIANO, 73, 30, G_BLACK},
    {5, 1, PIANO, 75, 31, G_BLACK},
    // row F: white keys, left to right (F G A B C D E F G A B C D E)
    {0, 6, PIANO, 53, 45, G_WHITE}, {0, 7, PIANO, 55, 44, G_WHITE}, {1, 6, PIANO, 57, 43, G_WHITE},
    {1, 7, PIANO, 59, 42, G_WHITE}, {2, 6, PIANO, 60, 41, G_WHITE}, {2, 7, PIANO, 62, 40, G_WHITE},
    {3, 6, PIANO, 64, 39, G_WHITE}, {3, 7, PIANO, 65, 38, G_WHITE}, {4, 6, PIANO, 67, 37, G_WHITE},
    {4, 7, PIANO, 69, 36, G_WHITE}, {5, 2, PIANO, 71, 35, G_WHITE}, {5, 3, PIANO, 72, 34, G_WHITE},
    {5, 4, PIANO, 74, 33, G_WHITE}, {5, 5, PIANO, 76, 32, G_WHITE},
};
const uint8_t KEY_CONTROL = 11, KEY_MINUS = 9, KEY_PLUS = 10;   // indices into KEYS
