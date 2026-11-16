// LMN-3 v3 (rev C) Teensy 4.1 firmware
// - 46 Hall-effect keys read through 6x 74HC4051 (velocity-sensitive piano, menu keys as CCs)
// - MIDI identical to the original LMN-3 firmware, so LMN-3-DAW works unchanged
// - 4 encoders + push, joystick (pitch bend, optional mod wheel + click)
// - 46 SK6812MINI-E per-key LEDs, optional colour control from the Pi over MIDI
// Derived from FundamentalFrequency/LMN-3-Firmware. License: GPL-3.0.
#include <Arduino.h>
#include <EEPROM.h>
#include <Encoder.h>
#include <WS2812Serial.h>
#include "engine.h"

static Engine eng;

// ---------------------------------------------------------------- MIDI out
void midiNoteOn(uint8_t note, uint8_t vel) { usbMIDI.sendNoteOn(note, vel, MIDI_CH); }
void midiNoteOff(uint8_t note, uint8_t vel) { usbMIDI.sendNoteOff(note, vel, MIDI_CH); }
void midiCC(uint8_t cc, uint8_t val) { usbMIDI.sendControlChange(cc, val, MIDI_CH); }
void midiPolyPressure(uint8_t note, uint8_t p) { usbMIDI.sendPolyPressure(note, p, MIDI_CH); }

// ---------------------------------------------------------------- key scanning
static uint8_t chanKeys[8][6], chanCount[8];

static void buildScanTable() {
    for (uint8_t i = 0; i < NUM_KEYS; i++) {
        uint8_t c = KEYS[i].ch;
        chanKeys[c][chanCount[c]++] = i;
    }
}

static inline void muxSelect(uint8_t c) {
    digitalWriteFast(PIN_MUX_S0, c & 1);
    digitalWriteFast(PIN_MUX_S1, (c >> 1) & 1);
    digitalWriteFast(PIN_MUX_S2, (c >> 2) & 1);
}

static uint16_t rawNow[NUM_KEYS];

// Read every key once. If `feed` is set, results go to the key engine.
static void scanKeys(bool feed) {
    for (uint8_t c = 0; c < 8; c++) {
        if (!chanCount[c]) continue;
        muxSelect(c);
        delayMicroseconds(MUX_SETTLE_US);
        uint32_t t = micros();
        uint32_t ms = millis();
        for (uint8_t j = 0; j < chanCount[c]; j++) {
            uint8_t i = chanKeys[c][j];
            rawNow[i] = analogRead(PIN_MUX_COM[KEYS[i].mux]);
            if (feed) eng.sample(i, rawNow[i], t, ms);
        }
    }
}

// ---------------------------------------------------------------- calibration storage
struct Store {
    uint32_t magic;
    uint16_t version;
    uint16_t rest[NUM_KEYS];
    uint16_t span[NUM_KEYS];
    uint8_t brightness;
    uint32_t sum;
};
static const uint32_t MAGIC = 0x334E4D4C;  // "LMN3"
static Store store;
static bool storeValid = false;
static uint32_t lastSaveMs = 0;
static uint8_t ledBrightness = LED_MAX_BRIGHTNESS;

static uint32_t checksum(const Store &s) {
    const uint8_t *p = (const uint8_t *)&s;
    uint32_t h = 2166136261u;
    for (size_t i = 0; i < offsetof(Store, sum); i++) h = (h ^ p[i]) * 16777619u;
    return h;
}

static void loadStore() {
    EEPROM.get(0, store);
    storeValid = store.magic == MAGIC && store.version == 1 && store.sum == checksum(store);
    if (storeValid) {
        for (uint8_t i = 0; i < NUM_KEYS; i++) eng.ks[i].span = max(store.span[i], MIN_SPAN);
        ledBrightness = min(store.brightness, LED_MAX_BRIGHTNESS);
    }
}

static void saveStore() {
    store.magic = MAGIC; store.version = 1;
    for (uint8_t i = 0; i < NUM_KEYS; i++) { store.rest[i] = eng.ks[i].rest16 / 16; store.span[i] = eng.ks[i].span; }
    store.brightness = ledBrightness;
    store.sum = checksum(store);
    EEPROM.put(0, store);
    storeValid = true;
    eng.spanDirty = false;
    lastSaveMs = millis();
}

// Measure resting values. A key held down at power-up keeps its stored rest value.
static void measureRest() {
    uint32_t acc[NUM_KEYS] = {0};
    const int N = 32;
    for (int n = 0; n < N; n++) { scanKeys(false); for (uint8_t i = 0; i < NUM_KEYS; i++) acc[i] += rawNow[i]; }
    for (uint8_t i = 0; i < NUM_KEYS; i++) {
        uint16_t r = acc[i] / N;
        if (storeValid && abs((int)r - (int)store.rest[i]) > eng.ks[i].span / 3) r = store.rest[i];
        eng.initRest(i, r);
    }
}

// ---------------------------------------------------------------- LEDs
static const int NUM_LEDS = NUM_KEYS;
static byte drawingMemory[NUM_LEDS * 3];
DMAMEM static byte displayMemory[NUM_LEDS * 12];
static WS2812Serial leds(NUM_LEDS, displayMemory, drawingMemory, PIN_LED_DATA, WS2812_GRB);

struct RGB { uint8_t r, g, b; };
static const RGB GROUP_COLOR[] = {
    {255, 120, 0},   // G_LOOP      amber
    {0, 190, 255},   // G_EDIT      cyan
    {150, 60, 255},  // G_FILE      violet
    {200, 200, 200}, // G_PLUSMINUS white
    {255, 190, 0},   // G_CONTROL   yellow
    {255, 0, 0},     // G_REC       red
    {0, 255, 40},    // G_PLAY      green
    {200, 200, 255}, // G_STOP      cool white
    {255, 0, 150},   // G_MIC       magenta
    {30, 70, 255},   // G_VIEW      blue
    {0, 0, 0}, {0, 0, 0}  // piano: depends on octave
};
// piano colour per transposition -4..+4
static const RGB OCTAVE_COLOR[9] = {
    {255, 0, 40}, {255, 30, 0}, {255, 80, 0}, {255, 150, 0}, {255, 190, 120},
    {0, 220, 255}, {0, 80, 255}, {120, 0, 255}, {255, 0, 200}};
// palette for host control (index 1..15; 0 = back to default)
static const RGB PALETTE[16] = {
    {0, 0, 0}, {255, 0, 0}, {255, 80, 0}, {255, 190, 0}, {120, 255, 0}, {0, 255, 40}, {0, 255, 180}, {0, 190, 255},
    {0, 60, 255}, {120, 0, 255}, {255, 0, 200}, {255, 0, 80}, {255, 255, 255}, {120, 120, 120}, {40, 40, 40}, {1, 1, 1}};
static uint8_t hostColor[NUM_KEYS];        // 0 = none
static uint32_t bootMs;

static inline uint8_t scale8(uint8_t v, uint8_t s) { return (uint16_t)v * s / 255; }

static void setKeyLed(uint8_t i, RGB c, uint8_t level) {
    uint8_t s = scale8(level, ledBrightness);
    leds.setPixel(KEYS[i].led, scale8(c.r, s), scale8(c.g, s), scale8(c.b, s));
}

static void renderLeds() {
    uint32_t now = millis();
    uint32_t age = now - bootMs;
    for (uint8_t i = 0; i < NUM_KEYS; i++) {
        const KeyState &k = eng.ks[i];
        RGB c = KEYS[i].type == PIANO ? OCTAVE_COLOR[eng.transposition + MAX_TRANSPOSITION] : GROUP_COLOR[KEYS[i].group];
        if (KEYS[i].group == G_BLACK) c = {(uint8_t)(c.r / 2), (uint8_t)(c.g / 2), (uint8_t)(c.b / 2)};
        if (hostColor[i]) c = PALETTE[hostColor[i] & 15];
        uint8_t level = LED_IDLE_LEVEL;
        if (k.state == K_ON) {
            level = KEYS[i].type == PIANO ? 100 + k.vel * 155 / 127 : 255;
        } else if (k.releaseMs && now - k.releaseMs < LED_FADE_MS) {
            uint8_t peak = KEYS[i].type == PIANO ? 100 + k.vel * 155 / 127 : 255;
            level = peak - (uint32_t)(peak - LED_IDLE_LEVEL) * (now - k.releaseMs) / LED_FADE_MS;
        }
        if ((i == KEY_PLUS || i == KEY_MINUS) && eng.controlHeld()) { c = GROUP_COLOR[G_CONTROL]; level = 255; }
        if (age < 800) {                       // power-up sweep along the board
            int d = abs((int)(age * NUM_LEDS / 600) - (int)KEYS[i].led);
            level = d < 4 ? 255 - d * 50 : 0;
        }
        setKeyLed(i, c, level);
    }
    leds.show();
}

// ---------------------------------------------------------------- encoders, buttons, joystick
static Encoder enc1(PIN_ENC[0][0], PIN_ENC[0][1]), enc2(PIN_ENC[1][0], PIN_ENC[1][1]),
               enc3(PIN_ENC[2][0], PIN_ENC[2][1]), enc4(PIN_ENC[3][0], PIN_ENC[3][1]);
static Encoder *encs[4] = {&enc1, &enc2, &enc3, &enc4};
static const uint8_t ENC_CC[4] = {ENCODER_1, ENCODER_2, ENCODER_3, ENCODER_4};
static const uint8_t ENC_BTN_CC[4] = {ENCODER_1_BUTTON, ENCODER_2_BUTTON, ENCODER_3_BUTTON, ENCODER_4_BUTTON};
static int32_t encBase[4];

static void updateEncoders() {
    for (int e = 0; e < 4; e++) {
        int32_t p = encs[e]->read();
        int32_t steps = (p - encBase[e]) / 4;          // 4 pulses per detent, as Control Surface
        if (steps) {
            encBase[e] += steps * 4;
            if (steps > 63) steps = 63;
            if (steps < -64) steps = -64;
            midiCC(ENC_CC[e], (uint8_t)(steps & 0x7F)); // relative, two's complement (1 = +1, 127 = -1)
            eng.lastActivityMs = millis();
        }
    }
}

struct Button { uint8_t pin, cc; bool state; uint32_t changed; };
static Button buttons[5] = {
    {PIN_ENC_SW[0], ENCODER_1_BUTTON, false, 0}, {PIN_ENC_SW[1], ENCODER_2_BUTTON, false, 0},
    {PIN_ENC_SW[2], ENCODER_3_BUTTON, false, 0}, {PIN_ENC_SW[3], ENCODER_4_BUTTON, false, 0},
    {PIN_JOY_SEL, JOYSTICK_BUTTON, false, 0}};

// Joystick up/down as the mod wheel: Control + joystick click switches it on
// and off. The choice is kept in its own EEPROM byte, away from the
// calibration store, so updating the firmware doesn't lose either.
static const int MOD_WHEEL_EEPROM = 4000;
static bool modWheelOn = ENABLE_MOD_WHEEL;
static bool joyClickWasToggle = false;   // that click belonged to Control (no CC 114)
static int lastMod = 0;

static void loadModWheel() {
    uint8_t v = EEPROM.read(MOD_WHEEL_EEPROM);
    if ((v & 0xFE) == 0xA0) modWheelOn = v & 1;
}

static void toggleModWheel() {
    modWheelOn = !modWheelOn;
    EEPROM.write(MOD_WHEEL_EEPROM, 0xA0 | (modWheelOn ? 1 : 0));
    if (!modWheelOn && lastMod != 0) { midiCC(MOD_WHEEL, 0); lastMod = 0; }
    midiCC(MOD_WHEEL_STATE, modWheelOn ? 127 : 0);   // LMN-3-DAW shows a message
}

static void updateButtons() {
    uint32_t now = millis();
    for (int b = 0; b < 5; b++) {
        if (b == 4 && !ENABLE_JOYSTICK_BUTTON) continue;
        bool pressed = digitalReadFast(buttons[b].pin) == LOW;
        if (pressed != buttons[b].state && now - buttons[b].changed > 5) {
            buttons[b].state = pressed; buttons[b].changed = now;
            eng.lastActivityMs = now;
            if (b == 4) {
                // joystick click: CC 114 (sustain in LMN-3-DAW), or with
                // Control held, switch the mod wheel
                if (pressed && eng.controlHeld()) { joyClickWasToggle = true; toggleModWheel(); continue; }
                if (!pressed && joyClickWasToggle) { joyClickWasToggle = false; continue; }
            }
            midiCC(buttons[b].cc, pressed ? 127 : 0);
        }
    }
}

static int32_t joyX, joyY, joyCX = 2048, joyCY = 2048;
static int lastBend = 0;
static uint32_t lastJoyMs;

static int axisToSigned(int32_t v, int32_t centre, int32_t full) {   // -> -full..+full with dead zone
    int32_t d = v - centre;
    if (abs(d) <= JOY_DEADZONE) return 0;
    if (d > 0) return (int)((d - JOY_DEADZONE) * full / max<int32_t>(4095 - centre - JOY_DEADZONE, 1));
    return (int)((d + JOY_DEADZONE) * full / max<int32_t>(centre - JOY_DEADZONE, 1));
}

static void updateJoystick() {
    uint32_t now = millis();
    if (now - lastJoyMs < 2) return;
    lastJoyMs = now;
    joyX += (analogRead(PIN_JOY_X) - joyX) / 4;
    int bend = axisToSigned(joyX, joyCX, 8191);
    if (JOY_X_INVERT) bend = -bend;
    if (bend > 8191) bend = 8191;
    if (bend < -8192) bend = -8192;
    if (abs(bend - lastBend) > 24 || (bend == 0 && lastBend != 0)) { usbMIDI.sendPitchBend(bend, MIDI_CH); lastBend = bend; }
    if (modWheelOn) {
        joyY += (analogRead(PIN_JOY_Y) - joyY) / 4;
        int mod = abs(axisToSigned(joyY, joyCY, 127));
        if (mod > 127) mod = 127;
        if (mod != lastMod) { midiCC(MOD_WHEEL, mod); lastMod = mod; }
    }
}

// ---------------------------------------------------------------- host LED control (Pi -> Teensy)
// Channel 16: Note On  key(0..45 = SW1..SW46), velocity = palette colour 1..15 (0 or Note Off = default)
//             CC 7 = brightness 0..127 (scaled to LED_MAX_BRIGHTNESS), CC 121 = clear all colours
static void handleHostMidi() {
    while (usbMIDI.read(HOST_LED_CHANNEL)) {
        uint8_t type = usbMIDI.getType(), d1 = usbMIDI.getData1(), d2 = usbMIDI.getData2();
        if (type == usbMIDI.NoteOn && d1 < NUM_KEYS) hostColor[d1] = d2 & 15;
        else if (type == usbMIDI.NoteOff && d1 < NUM_KEYS) hostColor[d1] = 0;
        else if (type == usbMIDI.ControlChange && d1 == 7) { ledBrightness = (uint16_t)d2 * LED_MAX_BRIGHTNESS / 127; eng.spanDirty = true; }
        else if (type == usbMIDI.ControlChange && d1 == 121) memset(hostColor, 0, sizeof hostColor);
    }
}

// ---------------------------------------------------------------- calibration mode
// Hold encoder 1's push button while powering up. Press every key all the way down once
// (its LED goes from red to green), then press encoder 1 again to save.
static void calibrationMode() {
    uint16_t maxTravel[NUM_KEYS] = {0};
    while (digitalReadFast(PIN_ENC_SW[0]) == LOW) delay(10);   // wait for release
    delay(50);
    uint32_t lastLed = 0;
    while (digitalReadFast(PIN_ENC_SW[0]) == HIGH) {
        scanKeys(false);
        for (uint8_t i = 0; i < NUM_KEYS; i++) {
            int t = abs((int)rawNow[i] - (int)(eng.ks[i].rest16 / 16));
            if (t > maxTravel[i]) maxTravel[i] = t;
        }
        if (millis() - lastLed > 20 && !leds.busy()) {
            lastLed = millis();
            for (uint8_t i = 0; i < NUM_KEYS; i++) {
                bool ok = maxTravel[i] >= 2 * MIN_SPAN;
                setKeyLed(i, ok ? RGB{0, 255, 0} : RGB{255, 0, 0}, 255);
            }
            leds.show();
        }
    }
    for (uint8_t i = 0; i < NUM_KEYS; i++)
        if (maxTravel[i] >= 2 * MIN_SPAN) eng.ks[i].span = max<uint16_t>(maxTravel[i] * 92 / 100, MIN_SPAN);
    saveStore();
    for (int n = 0; n < 3; n++) {                                // confirm: three green flashes
        for (uint8_t i = 0; i < NUM_KEYS; i++) setKeyLed(i, {0, 255, 0}, n % 2 ? 0 : 255);
        leds.show(); delay(150);
    }
    while (digitalReadFast(PIN_ENC_SW[0]) == LOW) delay(10);
}

// ---------------------------------------------------------------- debug (Teensy serial monitor)
static uint32_t scanCount, scanRateHz, lastRateMs;

static void debugConsole() {
    if (!Serial.available()) return;
    char c = Serial.read();
    if (c == 'p') {                       // key positions
        for (uint8_t i = 0; i < NUM_KEYS; i++)
            Serial.printf("SW%-2d raw %4u rest %4ld span %4u pos %4d %s\n", i + 1, rawNow[i], eng.ks[i].rest16 / 16,
                          eng.ks[i].span, eng.ks[i].pos, eng.ks[i].state == K_ON ? "ON" : "");
    } else if (c == 'r') {
        Serial.printf("scan rate %lu Hz, transposition %d, brightness %u\n", scanRateHz, eng.transposition, ledBrightness);
    } else if (c == 's') {
        saveStore(); Serial.println("saved");
    }
}

// ---------------------------------------------------------------- setup / loop
void setup() {
    pinMode(PIN_MUX_S0, OUTPUT); pinMode(PIN_MUX_S1, OUTPUT); pinMode(PIN_MUX_S2, OUTPUT);
    for (int e = 0; e < 4; e++) pinMode(PIN_ENC_SW[e], INPUT_PULLUP);
    pinMode(PIN_JOY_SEL, INPUT_PULLUP);
    analogReadResolution(12);
    analogReadAveraging(1);
    buildScanTable();
    leds.begin();
    loadStore();
    loadModWheel();
    measureRest();
    // joystick centre
    int32_t ax = 0, ay = 0;
    for (int n = 0; n < 32; n++) { ax += analogRead(PIN_JOY_X); ay += analogRead(PIN_JOY_Y); delay(1); }
    joyCX = joyX = ax / 32; joyCY = joyY = ay / 32;
    for (int e = 0; e < 4; e++) encBase[e] = encs[e]->read();
    if (digitalReadFast(PIN_ENC_SW[0]) == LOW) calibrationMode();
    for (int b = 0; b < 5; b++) buttons[b].state = digitalReadFast(buttons[b].pin) == LOW;  // no CC for buttons held at boot
    bootMs = millis();
}

void loop() {
    scanKeys(true);
    scanCount++;
    updateEncoders();
    updateButtons();
    updateJoystick();
    handleHostMidi();

    uint32_t now = millis();
    static uint32_t lastLedMs;
    if (now - lastLedMs >= 10 && !leds.busy()) { lastLedMs = now; renderLeds(); }
    if (now - lastRateMs >= 1000) { scanRateHz = scanCount * 1000 / (now - lastRateMs); scanCount = 0; lastRateMs = now; }
    // keep learned calibration: save after 15 s without playing, at most once a minute
    if (eng.spanDirty && now - eng.lastActivityMs > 15000 && now - lastSaveMs > 60000) saveStore();
    debugConsole();
}
