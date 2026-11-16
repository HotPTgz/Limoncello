// Key engine: Hall-effect travel -> menu CCs, velocity-sensitive notes, octave shift.
// Hardware independent (no pin access) so it can be unit-tested on a PC; see test/.
#pragma once
#include <stdint.h>
#include <stdlib.h>
#include <math.h>
#include "keymap.h"

// Provided by main.cpp (or by the test harness)
void midiNoteOn(uint8_t note, uint8_t vel);
void midiNoteOff(uint8_t note, uint8_t vel);
void midiCC(uint8_t cc, uint8_t val);
void midiPolyPressure(uint8_t note, uint8_t p);

enum : uint8_t { K_IDLE = 0, K_ON = 1, K_ARMED = 2 };

struct KeyState {
    int32_t rest16 = 0;        // resting ADC value x16
    uint16_t span = DEFAULT_SPAN;
    int16_t pos = 0, prevPos = 0;
    uint32_t prevT = 0;
    uint32_t tLow = 0;
    uint8_t state = K_IDLE;
    uint8_t note = 0, vel = 0, pressure = 0;
    uint8_t grow = 0;
    bool octaveMode = false;   // plus/minus pressed while Control was held
    uint32_t releaseMs = 0;    // for LED fade
};

struct Engine {
    KeyState ks[NUM_KEYS];
    int8_t transposition = 0;
    bool spanDirty = false;
    uint32_t lastActivityMs = 0;

    static uint8_t velocityFromDt(uint32_t dt) {
        if (dt <= VEL_FAST_US) return 127;
        if (dt >= VEL_SLOW_US) return 1;
        float f = (logf((float)dt) - logf((float)VEL_FAST_US)) / (logf((float)VEL_SLOW_US) - logf((float)VEL_FAST_US));
        float v = powf(1.0f - f, VEL_CURVE);
        int out = 1 + (int)lroundf(v * 126.0f);
        return (uint8_t)(out < 1 ? 1 : out > 127 ? 127 : out);
    }

    // time at which travel crossed `th` between two samples (linear interpolation)
    static uint32_t crossTime(int16_t th, int16_t p0, uint32_t t0, int16_t p1, uint32_t t1) {
        if (t0 == 0 || p1 <= p0 || th >= p1) return t1;
        if (th <= p0) return t0;
        return t0 + (uint32_t)((int64_t)(t1 - t0) * (th - p0) / (p1 - p0));
    }

    bool controlHeld() const { return ks[KEY_CONTROL].state == K_ON; }

    void initRest(uint8_t i, uint16_t rest) { ks[i].rest16 = (int32_t)rest * 16; }

    // Feed one ADC sample (12 bit) for key i taken at time t_us. nowMs is for bookkeeping.
    void sample(uint8_t i, uint16_t raw, uint32_t t_us, uint32_t nowMs) {
        KeyState &k = ks[i];
        int32_t rest = k.rest16 / 16;
        int32_t travel = abs((int32_t)raw - rest);
        if (travel > k.span) {                    // auto-range: only after 3 consistent samples
            if (++k.grow >= 3) { k.span = (uint16_t)(travel > 4095 ? 4095 : travel); k.grow = 0; spanDirty = true; }
        } else k.grow = 0;
        int32_t p = travel * 1000 / (k.span ? k.span : 1);
        if (p > 1100) p = 1100;
        k.prevPos = k.pos; k.pos = (int16_t)p;
        if (k.state == K_IDLE && k.pos < 30)      // follow slow drift (temperature) while untouched
            k.rest16 += ((int32_t)raw * 16 - k.rest16) >> 8;
        if (KEYS[i].type == MENU) menuKey(i, nowMs); else pianoKey(i, t_us, nowMs);
        k.prevT = t_us;
    }

    void menuKey(uint8_t i, uint32_t nowMs) {
        KeyState &k = ks[i];
        if (k.state == K_IDLE && k.pos >= MENU_PRESS) { k.state = K_ON; lastActivityMs = nowMs; menuEvent(i, true); }
        else if (k.state == K_ON && k.pos < MENU_RELEASE) { k.state = K_IDLE; k.releaseMs = nowMs; lastActivityMs = nowMs; menuEvent(i, false); }
    }

    void pianoKey(uint8_t i, uint32_t t, uint32_t nowMs) {
        KeyState &k = ks[i];
        if (k.state == K_IDLE && k.pos >= VEL_LOW) {
            k.tLow = crossTime(VEL_LOW, k.prevPos, k.prevT, k.pos, t);
            k.state = K_ARMED;
        }
        if (k.state == K_ARMED) {
            if (k.pos >= VEL_HIGH) {
                uint32_t tHigh = crossTime(VEL_HIGH, k.prevPos, k.prevT, k.pos, t);
                k.vel = velocityFromDt(tHigh - k.tLow);
                int n = KEYS[i].id + transposition * 12;
                k.note = (uint8_t)(n < 0 ? 0 : n > 127 ? 127 : n);
                k.pressure = 0;
                midiNoteOn(k.note, k.vel);
                k.state = K_ON; lastActivityMs = nowMs;
            } else if (k.pos < NOTE_OFF_POINT) {
                k.state = K_IDLE;                 // touched but not played
            }
        } else if (k.state == K_ON) {
            if (k.pos < NOTE_OFF_POINT) {
                midiNoteOff(k.note, 64);
                k.state = K_IDLE; k.releaseMs = nowMs; lastActivityMs = nowMs;
            } else if (ENABLE_POLY_AFTERTOUCH) {
                int pr = k.pos <= AFTERTOUCH_START ? 0 : (k.pos - AFTERTOUCH_START) * 127 / (1000 - AFTERTOUCH_START);
                if (pr > 127) pr = 127;
                if (abs(pr - (int)k.pressure) >= 2 || (pr == 0 && k.pressure)) { k.pressure = (uint8_t)pr; midiPolyPressure(k.note, k.pressure); }
            }
        }
    }

    // Same behaviour as the original firmware: Plus/Minus send CC 118/119, or change octave
    // (CC 117 = transposition + 4) on release when pressed while Control is held.
    void menuEvent(uint8_t i, bool pressed) {
        if (i == KEY_PLUS || i == KEY_MINUS) {
            KeyState &k = ks[i];
            if (pressed) {
                k.octaveMode = controlHeld();
                if (!k.octaveMode) midiCC(KEYS[i].id, 127);
            } else if (k.octaveMode) {
                int t = transposition + (i == KEY_PLUS ? 1 : -1);
                if (t >= -MAX_TRANSPOSITION && t <= MAX_TRANSPOSITION) transposition = (int8_t)t;
                midiCC(OCTAVE_CHANGE, (uint8_t)(transposition + MAX_TRANSPOSITION));
                k.octaveMode = false;
            } else {
                midiCC(KEYS[i].id, 0);
            }
            return;
        }
        midiCC(KEYS[i].id, pressed ? 127 : 0);
    }
};
