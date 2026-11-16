// LMN-3 Hall-effect key test (4 keys, rev C footprints) for Teensy 4.1
// USB type must be "Serial + MIDI".
//
// Wiring (test board J1 -> Teensy 4.1):
//   3V3 -> 3.3V    GND -> GND    5V -> VIN (USB 5 V)    LED -> pin 17
//   K1 -> pin 14 (A0)   K2 -> pin 15 (A1)   K3 -> pin 16 (A2)   K4 -> pin 18 (A4)
//   (the same Teensy pins the rev C board uses)
//
// Keep your hands off the keys for the first 2 seconds after power-up (rest calibration).
// Serial commands (Teensy serial monitor or Arduino Serial Monitor/Plotter, any baud):
//   p  stream raw readings for the Serial Plotter (default)    r  report + PASS/CHECK verdict
//   v  log each note (time between thresholds, velocity)       c  clear min/max
//   q  quiet (stop streaming)                                  h  help
// MIDI: keys play notes 60 62 64 65 (C D E F) with velocity, so you can try them in any synth.
#include <WS2812Serial.h>

const uint8_t NKEYS = 4;
const uint8_t KEY_PIN[NKEYS] = {14, 15, 16, 18};
const uint8_t NOTE[NKEYS] = {60, 62, 64, 65};
const uint8_t LED_PIN = 17;

// pass criteria
const int MIN_SWING = 200;        // ADC counts (of 4096) between rest and fully pressed
const int MAX_NOISE_PP = 10;      // peak-to-peak jitter at rest
const float MAX_MISMATCH = 0.30;  // swing of each key within +-30 % of the average

// velocity (same scheme as the rev C firmware)
const int VEL_LOW = 150, VEL_HIGH = 700, NOTE_OFF = 100;   // per-mille of travel
const uint32_t VEL_FAST_US = 3000, VEL_SLOW_US = 60000;
const float VEL_CURVE = 1.4f;
const int DEFAULT_SWING = 300;    // until a key has been pressed fully once

byte drawingMemory[NKEYS * 3];
DMAMEM byte displayMemory[NKEYS * 12];
WS2812Serial leds(NKEYS, displayMemory, drawingMemory, LED_PIN, WS2812_GRB);

struct Key {
  float rest = 0, noiseStd = 0;
  int noisePP = 0;
  int minRaw = 4095, maxRaw = 0;   // since boot / last 'c'
  int raw = 0;
  int pos = 0, prevPos = 0;        // per-mille
  uint32_t prevT = 0, tLow = 0;
  uint8_t state = 0;               // 0 idle, 1 armed, 2 on
  uint8_t vel = 0;
  uint32_t flashMs = 0;
} k[NKEYS];

char mode = 'p';
uint32_t scans = 0, scanRate = 0, lastRateMs = 0, lastStreamMs = 0, lastLedMs = 0;

int swingOf(const Key &q) {        // largest deviation seen from rest, either direction
  return max(abs(q.maxRaw - (int)q.rest), abs((int)q.rest - q.minRaw));
}

uint8_t velocityFromDt(uint32_t dt) {
  if (dt <= VEL_FAST_US) return 127;
  if (dt >= VEL_SLOW_US) return 1;
  float f = (logf(dt) - logf(VEL_FAST_US)) / (logf(VEL_SLOW_US) - logf(VEL_FAST_US));
  return 1 + (uint8_t)lroundf(powf(1 - f, VEL_CURVE) * 126);
}

uint32_t crossTime(int th, int p0, uint32_t t0, int p1, uint32_t t1) {
  if (t0 == 0 || p1 <= p0 || th >= p1) return t1;
  if (th <= p0) return t0;
  return t0 + (uint32_t)((int64_t)(t1 - t0) * (th - p0) / (p1 - p0));
}

void calibrateRest() {
  const int N = 2000;               // ~2 s
  for (int i = 0; i < NKEYS; i++) {
    double s = 0, s2 = 0; int lo = 4095, hi = 0;
    for (int n = 0; n < N / NKEYS; n++) {
      int r = analogRead(KEY_PIN[i]);
      s += r; s2 += (double)r * r; lo = min(lo, r); hi = max(hi, r);
      delayMicroseconds(250);
    }
    int n = N / NKEYS;
    k[i].rest = s / n;
    k[i].noiseStd = sqrt(max(0.0, s2 / n - (s / n) * (s / n)));
    k[i].noisePP = hi - lo;
    k[i].minRaw = k[i].maxRaw = (int)k[i].rest;
  }
}

void report() {
  Serial.println();
  Serial.println("key  rest   noise(pp/std)  min   max   swing  polarity  result");
  int swings[NKEYS]; float avg = 0;
  for (int i = 0; i < NKEYS; i++) { swings[i] = swingOf(k[i]); avg += swings[i]; }
  avg /= NKEYS;
  bool all = true;
  for (int i = 0; i < NKEYS; i++) {
    const Key &q = k[i];
    bool up = (q.maxRaw - q.rest) >= (q.rest - q.minRaw);
    bool okSwing = swings[i] >= MIN_SWING;
    bool okNoise = q.noisePP <= MAX_NOISE_PP;
    bool okMatch = avg > 0 && fabsf(swings[i] - avg) <= MAX_MISMATCH * avg;
    bool ok = okSwing && okNoise && okMatch;
    all &= ok;
    Serial.printf("K%d  %6.1f   %3d / %4.1f    %4d  %4d   %4d   %s      %s%s%s%s\n", i + 1, q.rest, q.noisePP, q.noiseStd,
                  q.minRaw, q.maxRaw, swings[i], up ? "rises " : "falls ", ok ? "PASS" : "CHECK",
                  okSwing ? "" : " (swing too small)", okNoise ? "" : " (noisy)", okMatch ? "" : " (differs from others)");
  }
  Serial.printf("scan rate %lu Hz. Press every key fully a few times before reading this.\n", scanRate);
  Serial.println(all ? ">>> ALL PASS: the sensor + switch combination is fine for rev C."
                     : ">>> CHECK: see the README (what the numbers mean).");
}

void help() {
  Serial.println("\nLMN-3 HE key test. Commands: p plot, r report, v velocity log, c clear min/max, q quiet, h help");
}

void setup() {
  analogReadResolution(12);
  analogReadAveraging(1);          // same as the rev C firmware, so the noise you see is the real one
  leds.begin();
  for (int i = 0; i < NKEYS; i++) leds.setPixel(i, 0, 0, 30);
  leds.show();
  delay(300);
  calibrateRest();
  for (int i = 0; i < NKEYS; i++) leds.setPixel(i, 0, 30, 0);
  leds.show();
  Serial.begin(115200);
}

void loop() {
  uint32_t t = micros(), ms = millis();
  for (int i = 0; i < NKEYS; i++) {
    Key &q = k[i];
    q.raw = analogRead(KEY_PIN[i]);
    q.minRaw = min(q.minRaw, q.raw); q.maxRaw = max(q.maxRaw, q.raw);
    int span = max(swingOf(q), DEFAULT_SWING);
    q.prevPos = q.pos;
    q.pos = constrain((int)(fabsf(q.raw - q.rest) * 1000 / span), 0, 1100);
    if (q.state == 0 && q.pos >= VEL_LOW) { q.tLow = crossTime(VEL_LOW, q.prevPos, q.prevT, q.pos, t); q.state = 1; }
    if (q.state == 1) {
      if (q.pos >= VEL_HIGH) {
        uint32_t tHigh = crossTime(VEL_HIGH, q.prevPos, q.prevT, q.pos, t);
        q.vel = velocityFromDt(tHigh - q.tLow);
        usbMIDI.sendNoteOn(NOTE[i], q.vel, 1);
        q.state = 2; q.flashMs = ms;
        if (mode == 'v') Serial.printf("K%d note on  dt %6lu us  velocity %3d\n", i + 1, tHigh - q.tLow, q.vel);
      } else if (q.pos < NOTE_OFF) q.state = 0;
    } else if (q.state == 2 && q.pos < NOTE_OFF) {
      usbMIDI.sendNoteOff(NOTE[i], 64, 1);
      q.state = 0;
    }
    q.prevT = t;
  }
  scans++;
  while (usbMIDI.read()) {}         // ignore incoming MIDI

  if (ms - lastRateMs >= 1000) { scanRate = scans * 1000 / (ms - lastRateMs); scans = 0; lastRateMs = ms; }
  if (mode == 'p' && ms - lastStreamMs >= 10) {   // 100 Hz for the Serial Plotter
    lastStreamMs = ms;
    Serial.printf("K1:%d K2:%d K3:%d K4:%d\n", k[0].raw, k[1].raw, k[2].raw, k[3].raw);
  }
  if (ms - lastLedMs >= 15 && !leds.busy()) {     // LED colour follows key travel: blue -> red, green flash on a note
    lastLedMs = ms;
    for (int i = 0; i < NKEYS; i++) {
      int p = min(k[i].pos, 1000);
      uint8_t r = p * 60 / 1000, b = (1000 - p) * 20 / 1000, g = 0;
      if (ms - k[i].flashMs < 120) { r = 0; g = 30 + k[i].vel / 2; b = 0; }
      leds.setPixel(i, r, g, b);
    }
    leds.show();
  }
  if (Serial.available()) {
    char c = Serial.read();
    if (c == 'r') { mode = 'q'; report(); }
    else if (c == 'c') { for (auto &q : k) q.minRaw = q.maxRaw = (int)q.rest; Serial.println("min/max cleared"); }
    else if (c == 'p' || c == 'v' || c == 'q') mode = c;
    else if (c == 'h') { mode = 'q'; help(); }
  }
}
