#pragma once
struct EEPROMStub { template<class T> void get(int, T &t) { memset(&t, 0, sizeof t); } template<class T> void put(int, const T &) {}     uint8_t mem[4284] = {};
    uint8_t read(int a) { return mem[a]; }
    void write(int a, uint8_t v) { mem[a] = v; }
};
static EEPROMStub EEPROM;
