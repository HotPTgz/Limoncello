// Minimal host stubs so the firmware compiles and the key engine can be tested on a PC.
#pragma once
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdio.h>
#include <math.h>
#include <algorithm>
typedef uint8_t byte;
#define HIGH 1
#define LOW 0
#define OUTPUT 1
#define INPUT_PULLUP 2
#define DMAMEM
using std::min; using std::max;
extern uint32_t g_micros;
inline uint32_t micros() { return g_micros; }
inline uint32_t millis() { return g_micros / 1000; }
inline void delay(uint32_t) {}
inline void delayMicroseconds(uint32_t) {}
inline void pinMode(int, int) {}
inline void digitalWriteFast(int, int) {}
inline int digitalReadFast(int) { return HIGH; }
int analogRead(int pin);
inline void analogReadResolution(int) {}
inline void analogReadAveraging(int) {}
struct SerialStub { int available() { return 0; } int read() { return -1; } template<class... A> void printf(const char *f, A... a) { ::printf(f, a...); } void println(const char *s) { puts(s); } };
extern SerialStub Serial;
struct UsbMidiStub {
    enum { NoteOff = 0x80, NoteOn = 0x90, ControlChange = 0xB0 };
    void sendNoteOn(uint8_t, uint8_t, uint8_t); void sendNoteOff(uint8_t, uint8_t, uint8_t);
    void sendControlChange(uint8_t, uint8_t, uint8_t); void sendPolyPressure(uint8_t, uint8_t, uint8_t);
    void sendPitchBend(int, uint8_t);
    bool read(uint8_t = 0) { return false; } uint8_t getType() { return 0; } uint8_t getData1() { return 0; } uint8_t getData2() { return 0; }
};
extern UsbMidiStub usbMIDI;
