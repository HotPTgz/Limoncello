// Host unit tests for the key engine:  g++ -std=c++17 -Imock -I../src test_engine.cpp && ./a.out
#include "Arduino.h"
#include "engine.h"
#include <vector>
#include <string>
#include <cassert>
uint32_t g_micros = 0;
struct Ev { char t; int a, b; };
std::vector<Ev> ev;
void midiNoteOn(uint8_t n, uint8_t v) { ev.push_back({'N', n, v}); }
void midiNoteOff(uint8_t n, uint8_t v) { ev.push_back({'F', n, v}); }
void midiCC(uint8_t c, uint8_t v) { ev.push_back({'C', c, v}); }
void midiPolyPressure(uint8_t n, uint8_t p) { ev.push_back({'P', n, p}); }

Engine e;
const int REST = 2048, SPAN = 400, SCAN_US = 300;
int fails = 0;
#define CHECK(c, msg) do { if (!(c)) { printf("FAIL: %s\n", msg); fails++; } else printf("ok   %s\n", msg); } while (0)

void reset() { e = Engine(); for (int i = 0; i < NUM_KEYS; i++) { e.initRest(i, REST); e.ks[i].span = SPAN; } ev.clear(); }
// move key i from travel a to b (per-mille) over dur_us, sampling every SCAN_US; sign = magnet polarity
void move(int i, int a, int b, uint32_t dur, int sign = 1) {
    int n = std::max<int>(1, dur / SCAN_US);
    for (int s = 1; s <= n; s++) {
        g_micros += SCAN_US;
        int p = a + (b - a) * s / n;
        e.sample(i, REST + sign * p * SPAN / 1000, g_micros, millis());
    }
}
void idle(int i, int ms) { for (int t = 0; t < ms * 1000; t += SCAN_US) { g_micros += SCAN_US; e.sample(i, REST, g_micros, millis()); } }
int find(char t) { for (auto &x : ev) if (x.t == t) return &x - &ev[0]; return -1; }

int main() {
    g_micros = 1000;
    // 1 menu key: Loop (SW1)
    reset(); idle(0, 5); move(0, 0, 1000, 5000); idle(0, 0); move(0, 1000, 0, 5000);
    CHECK(ev.size() == 2 && ev[0].t == 'C' && ev[0].a == LOOP_BUTTON && ev[0].b == 127 && ev[1].b == 0, "menu key sends CC 105 127 then 0");
    // 2 hysteresis: hovering between release and press points -> nothing
    reset(); move(0, 0, 450, 3000); move(0, 450, 320, 3000); move(0, 320, 480, 3000);
    CHECK(ev.empty(), "menu key below actuation point sends nothing");
    // 3 piano velocity: white key C (SW37, index 36) note 60
    const int C4 = 36;
    reset(); idle(C4, 5); move(C4, 0, 1000, 3000);
    int vFast = ev.size() ? ev[0].b : -1;
    CHECK(ev.size() == 1 && ev[0].t == 'N' && ev[0].a == 60 && vFast >= 120, "fast press -> note 60, velocity >= 120");
    move(C4, 1000, 0, 5000);
    CHECK(ev.size() == 2 && ev[1].t == 'F' && ev[1].a == 60, "release -> note off 60");
    reset(); idle(C4, 5); move(C4, 0, 1000, 150000);
    CHECK(ev.size() == 1 && ev[0].b <= 5, "very slow press (150 ms) -> velocity <= 5");
    std::vector<int> vs;
    for (uint32_t d : {4000u, 8000u, 15000u, 30000u, 50000u}) { reset(); idle(C4, 5); move(C4, 0, 1000, d); vs.push_back(ev[0].b); }
    bool mono = true; for (size_t i = 1; i < vs.size(); i++) mono &= vs[i] < vs[i - 1];
    printf("     velocities 4/8/15/30/50 ms: %d %d %d %d %d\n", vs[0], vs[1], vs[2], vs[3], vs[4]);
    CHECK(mono, "velocity decreases as the press gets slower");
    // 4 reversed magnet polarity
    reset(); idle(C4, 5); move(C4, 0, 1000, 3000, -1); move(C4, 1000, 0, 3000, -1);
    CHECK(ev.size() == 2 && ev[0].t == 'N' && ev[1].t == 'F', "works with the magnet the other way round");
    // 5 touch without playing
    reset(); idle(C4, 5); move(C4, 0, 400, 5000); move(C4, 400, 0, 5000);
    CHECK(ev.empty(), "half press (below note-on point) plays nothing");
    // 6 plus without control -> CC 118
    reset(); move(KEY_PLUS, 0, 1000, 3000); move(KEY_PLUS, 1000, 0, 3000);
    CHECK(ev.size() == 2 && ev[0].a == PLUS_BUTTON && ev[0].b == 127 && ev[1].b == 0, "Plus alone sends CC 118 127/0");
    // 7 control + plus -> octave up, CC117 = 5, notes transposed; held note released on the old pitch
    reset(); idle(C4, 2);
    move(C4, 0, 1000, 3000);                                  // hold C4 (note 60)
    move(KEY_CONTROL, 0, 1000, 3000);
    move(KEY_PLUS, 0, 1000, 3000); move(KEY_PLUS, 1000, 0, 3000);
    move(KEY_CONTROL, 1000, 0, 3000);
    move(C4, 1000, 0, 3000);                                  // release: must be note off 60
    move(C4, 0, 1000, 3000);                                  // new press: note 72
    std::string s; for (auto &x : ev) { char b[32]; snprintf(b, 32, "%c%d:%d ", x.t, x.a, x.b); s += b; }
    printf("     events: %s\n", s.c_str());
    bool hasOct = false, off60 = false, on72 = false, plusCC = false;
    for (auto &x : ev) { hasOct |= x.t == 'C' && x.a == OCTAVE_CHANGE && x.b == 5; off60 |= x.t == 'F' && x.a == 60; on72 |= x.t == 'N' && x.a == 72; plusCC |= x.t == 'C' && x.a == PLUS_BUTTON; }
    CHECK(hasOct && off60 && on72 && !plusCC, "Control+Plus: CC117=5, held note off on 60, next note 72, no CC118");
    // 8 octave clamp at +4
    reset(); move(KEY_CONTROL, 0, 1000, 3000);
    for (int n = 0; n < 6; n++) { move(KEY_PLUS, 0, 1000, 3000); move(KEY_PLUS, 1000, 0, 3000); }
    CHECK(e.transposition == 4 && ev.back().a == OCTAVE_CHANGE && ev.back().b == 8, "octave clamps at +4 (CC117 = 8)");
    // 9 auto-range: magnet gives more travel than the default span
    reset(); e.ks[C4].span = DEFAULT_SPAN; idle(C4, 2);
    for (int s = 0; s < 10; s++) { g_micros += SCAN_US; e.sample(C4, REST + 900, g_micros, millis()); }
    CHECK(e.ks[C4].span == 900 && e.spanDirty, "span grows to the real travel and is marked for saving");
    // 10 crossTime / first sample safety
    CHECK(Engine::crossTime(500, 0, 1000, 1000, 2000) == 1500, "crossing time interpolation");
    printf(fails ? "\n%d FAILED\n" : "\nall tests passed\n", fails);
    return fails != 0;
}
