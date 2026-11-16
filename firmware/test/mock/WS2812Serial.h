#pragma once
#define WS2812_GRB 0
struct WS2812Serial { WS2812Serial(int, void *, void *, int, int) {} void begin() {} bool busy() { return false; }
  void setPixel(uint32_t, uint8_t, uint8_t, uint8_t) {} void show() {} };
