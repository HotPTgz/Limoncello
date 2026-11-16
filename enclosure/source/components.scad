// LMN-3 v3 rev C: everything together, for renders. Simplified stand-ins at their real positions.
// z = 0 is the PCB top; board coords via at() from lmn3_v3_case.scad.
include <lmn3_v3_case.scad>
view = "top";          // top | under | exploded | cut | pi
SHOW_SCREEN = true;
SHOW_CASE = false;
SHOW_POSTS = true;

PI_TOP = -PCB_T - 11;  // Pi top surface (faces up), hangs under the PCB on the header (2.5 + 8.5 mm)
module bx(x0, y0, x1, y1, z0, z1) { translate([x0, 180 - y1, z0]) cube([x1 - x0, y1 - y0, z1 - z0]); }

module pcb() {
    color([0.05, 0.32, 0.12]) translate([0, 0, -PCB_T]) linear_extrude(PCB_T) difference() {
        offset(3) offset(-3) square([330, 180]);
        for (s = SPEAKERS) translate(T(s)) circle(r = 21);
        translate(T([0, 0])) mirror([0, 1]) polygon(PCB_OPENING);
        for (k = KEYS) translate(T([k[1], k[2] + 5.08])) square([3.4, 3], center = true);
    }
}
// ---- Raspberry Pi 5: the official Raspberry Pi STEP model (MIT), meshed. Pi coords -> board: x = 197 - px, y = 1 + py
PI_STEP_TOP = 1.31;    // top face of the board in the STEP
module pi5() {
    color([0.78, 0.79, 0.8]) translate([197, 179, PI_TOP - PI_STEP_TOP]) rotate([0, 0, 180]) import("pi5_official.stl");
    // green over the bare board so it reads as a PCB (holes kept)
    color([0.1, 0.45, 0.2]) translate([0, 0, PI_TOP - 1.3]) linear_extrude(1.32) difference() {
        translate([112 - 0.02, T([0, 57])[1] - 0.02]) offset(3) offset(-3) square([85.04, 56.04]);
        for (h = [[3.5, 3.5], [61.5, 3.5], [3.5, 52.5], [61.5, 52.5], [3.5, 9.5], [61.5, 46.5]]) translate(T([197 - h[0], 1 + h[1]])) circle(d = 2.75);
    }
    active_cooler();
    // H12 stand-off (M2.5) between the Pi and the PCB, and the 3 tray posts
    color([0.72, 0.6, 0.25]) at([135.5, 53.5]) translate([0, 0, PI_TOP]) cylinder(d = 5, h = -PCB_T - PI_TOP, $fn = 6);
}
// ---- Raspberry Pi Active Cooler, from the official mechanical drawing (63.5 x 42.5 x 13.7 incl. push pins).
// Drawing coords (dx from its left, dy from its bottom) -> board x = 196.5 - dx, board y = 7.5 + dy
module ac(dx0, dy0, dx1, dy1, z0, z1) bx(196.5 - dx1, 7.5 + dy0, 196.5 - dx0, 7.5 + dy1, z0, z1);
AC_OUTLINE = [[0, 0], [30, 0], [43, 12.5], [63.5, 12.5], [63.5, 42.5], [6.7, 42.5], [6.7, 9.5], [0, 4.5]];
module active_cooler() {
    zb = PI_TOP + 0.6;  zt = PI_TOP + 10.5;           // base plate rests on the SoC; body top 10.5 above the Pi
    color([0.55, 0.57, 0.62]) translate([196.5, 180 - 7.5, zb]) mirror([1, 0]) mirror([0, 1]) linear_extrude(1.6) polygon(AC_OUTLINE);
    color([0.62, 0.64, 0.69]) for (i = [0:5], j = [0:8]) ac(7.0 + i * 3.3, 1.0 + j * 4.6, 9.0 + i * 3.3, 4.2 + j * 4.6, zb + 1.6, zt);   // pin fins
    // blower: 30 x 30 housing, round intake on top
    color([0.13, 0.13, 0.14]) difference() {
        ac(27, 12.5, 57, 42.5, zb + 1.6, zt);
        translate([196.5 - 42, 180 - 7.5 - 27.5, zt - 0.6]) cylinder(d = 20.5, h = 1);
    }
    color([0.3, 0.3, 0.33]) translate([196.5 - 42, 180 - 7.5 - 27.5, zt - 1.2]) for (a = [0:30:359]) rotate(a) translate([3.5, -0.5, 0]) cube([6.5, 1, 0.6]);
    color([0.3, 0.3, 0.33]) translate([196.5 - 42, 180 - 7.5 - 27.5, zt - 1.2]) cylinder(d = 7, h = 0.7);
    // spring-loaded push pins in the Pi's two heatsink holes
    color([0.85, 0.85, 0.85]) for (h = [[3.5, 9.5], [61.5, 46.5]]) at([197 - h[0], 1 + h[1]]) {
        translate([0, 0, PI_TOP - 2.9]) cylinder(d = 2.4, h = 13.7 - 0.5);
        translate([0, 0, zb + 1.6]) cylinder(d = 5.2, h = zt - zb - 1.6, $fn = 6);
    }
}
module tray_posts() for (p = PI_POSTS) at(p) {
    color([0.75, 0.75, 0.75]) translate([0, 0, FLOOR_Z]) cylinder(d = 7, h = PI_BOT_Z - PI_SPACER - FLOOR_Z);
    color([0.72, 0.6, 0.25]) translate([0, 0, PI_BOT_Z - PI_SPACER]) cylinder(d = 5, h = PI_SPACER, $fn = 6);   // brass F-F stand-off
}
module j2_socket() color([0.12, 0.12, 0.12]) bx(140.5, 50, 191, 56, -PCB_T - 8.5, -PCB_T);
// ---- Codec Zero, from the official product brief (65 x 31, M2.5 holes 58 x 23 at 3.5 mm from the edges).
// It hangs component side down; its own coords (cx from its left, cy from its bottom, header on top) -> board x = 270 - cx, board y = 42 - cy
module cz(cx0, cy0, cx1, cy1, z0, z1) bx(270 - cx1, 42 - cy1, 270 - cx0, 42 - cy0, z0, z1);
module codec_zero() {
    z = -PCB_T - 2.5 - 8.5;                                                             // its header-side face (faces up)
    color([0.12, 0.12, 0.12]) bx(212, 12.5, 263, 17.5, -PCB_T - 2.5, -PCB_T);         // J3 plastic
    color([0.1, 0.1, 0.1]) bx(212, 12.5, 263, 17.5, z, -PCB_T - 2.5);                 // its female header
    color([0.1, 0.5, 0.22]) translate([0, 0, z - 1.6]) linear_extrude(1.6) difference() {
        translate(T([205, 42])) offset(3) offset(-3) square([65, 31]);
        for (hx = [3.5, 61.5], hy = [3.5, 26.5]) translate(T([270 - hx, 42 - hy])) circle(d = 2.75);
    }
    color([0.08, 0.08, 0.08]) cz(22, 12, 29, 19, z - 2.6, z - 1.6);                  // DA7212 codec
    color([0.15, 0.15, 0.15]) cz(13.8, -1.2, 21.2, 11, z - 6.6, z - 1.6);             // 3.5 mm mic socket at 17.5 on the bottom edge
    color([0.15, 0.45, 0.2]) cz(48.6, 0, 58.5, 8, z - 11, z - 1.6);                   // speaker screw terminal (x 48.6-58.5)
    color([0.2, 0.2, 0.2]) cz(39.6, 3.5, 44.4, 8.3, z - 3.5, z - 1.6);                // button at 42
}
module teensy() {
    z = -PCB_T - 2.5;
    color([0.12, 0.12, 0.12]) for (s = [0, 1]) bx(31, 70.8 + s * 15.2, 91, 72.2 + s * 15.2, z, -PCB_T);   // pin strips
    color([0.1, 0.42, 0.2]) bx(30, 70.6, 91, 88.5, z - 1.6, z);
    color([0.1, 0.1, 0.1]) bx(55, 75, 67, 84, z - 2.6, z - 1.6);                      // i.MX RT1062
    color([0.8, 0.8, 0.82]) bx(87, 75.5, 92.5, 83.5, z - 4.4, z - 1.6);               // micro-USB
    color([0.85, 0.85, 0.8]) bx(31, 74, 42, 85, z - 3.5, z - 1.6);                    // SD socket
}
module smd_bits() {   // amp, muxes, LDO, level shifter, caps (bottom side), JST connectors
    color([0.1, 0.1, 0.1]) { bx(233, 51, 239, 61, -PCB_T - 1.7, -PCB_T);              // PAM8403
        for (x = [73.1, 101.9, 143.6, 185.2, 224.5, 283.4]) bx(x - 5, 128.6, x + 5, 132.6, -PCB_T - 1.7, -PCB_T);
        bx(10, 76.5, 16, 83.5, -PCB_T - 1.8, -PCB_T); bx(22.5, 67, 25.5, 69, -PCB_T - 1.2, -PCB_T); }
    color([0.9, 0.9, 0.85]) for (p = [[212, 50, 8], [258, 68, 6], [266, 68, 6], [214, 84, 6]]) bx(p[0] - p[2] / 2, p[1] - 2.5, p[0] + p[2] / 2, p[1] + 2.5, -PCB_T - 6, -PCB_T);
    color([0.6, 0.45, 0.3]) for (c = [[226, 50], [246, 50], [150, 61], [158, 61], [6, 72], [6, 88]]) bx(c[0] - 1.6, c[1] - 0.8, c[0] + 1.6, c[1] + 0.8, -PCB_T - 1.2, -PCB_T);
}
module top_side() {
    if (SHOW_SCREEN) {
    color([0.2, 0.21, 0.24]) screen_model();
    color([0.02, 0.02, 0.05]) translate([(SCREEN[0] + SCREEN[2]) / 2 - 95.54, T([0, (SCREEN[1] + SCREEN[3]) / 2])[1] - 30.2, GLASS_Z - 0.14]) cube([191.08, 60.4, 0.1]);   // active area (centred, per the model)
    }
    for (s = SPEAKERS) at(s) { color([0.55, 0.55, 0.58]) translate([0, 0, 4.5]) cylinder(d = 22, h = 8); color([0.2, 0.2, 0.2]) translate([0, 0, 12.5]) cylinder(d1 = 30, d2 = 40, h = 11.5); color([0.35, 0.35, 0.35]) translate([0, 0, 23.5]) difference() { cylinder(d = 40, h = 1); translate([0, 0, -1]) cylinder(d = 34, h = 3); } }
    for (k = KEYS) at([k[1], k[2]]) {
        color([0.85, 0.88, 0.95, 0.85]) translate([-7, -7, 0]) cube([14, 14, 11.6]);   // magnetic switch housing
        color([0.95, 0.5, 0.2]) translate([-2.5, -2.5, 11.6]) cube([5, 5, 0.6]);        // stem
        color([0.1, 0.1, 0.1]) translate([-0.7, -1.5, 0]) cube([1.4, 3, 1]);            // Hall sensor
    }
    color([0.25, 0.25, 0.25]) plate();
    for (e = ENCODERS) at(e) { color([0.2, 0.2, 0.22]) translate([-6, -6, 0]) cube([12, 12, 6.5]); color("silver") cylinder(d = 6, h = ENC_SHAFT_TOP); }
    at(JOYSTICK) { color([0.15, 0.15, 0.15]) translate([-9, -9, 0]) cube([18, 18, 11]); color([0.2, 0.2, 0.2]) cylinder(d = 5, h = 24); color([0.1, 0.1, 0.1]) translate([0, 0, 24]) cylinder(d = 16, h = 6); }
    color([0.7, 0.7, 0.7]) translate([311.2, T([0, 80.7])[1], 0]) cube([19, 9.2, 5.5]);   // headphone jack
    at(MIC) color([0.2, 0.2, 0.2]) cylinder(d = 6, h = 5);
}
module keys_and_knobs() {
    for (k = KEYS) at([k[1], k[2]]) color(k[3] == 2 ? [0.12, 0.12, 0.12] : [0.97, 0.97, 0.97]) tile(k[3] == 2 ? Z_TOP + BLACK_UP : Z_TOP, k[4]);
    for (e = ENCODERS) at(e) color([0.18, 0.18, 0.2]) knob();
}
module electronics(dz_top = 0, dz_bot = 0) {
    pcb(); translate([0, 0, dz_top]) top_side();
    translate([0, 0, -dz_bot]) { pi5(); codec_zero(); } teensy(); j2_socket(); smd_bits();
    if (SHOW_POSTS) translate([0, 0, -dz_bot]) tray_posts();
}

if (view == "top") { electronics(); keys_and_knobs(); }
if (view == "under") { rotate([180, 0, 0]) translate([0, 0, 0]) electronics(); }
if (view == "exploded") {
    translate([0, 0, 120]) color([0.92, 0.92, 0.9]) top_shell();
    translate([0, 0, 60]) keys_and_knobs();
    electronics();
    translate([0, 0, -60]) color([0.75, 0.75, 0.75]) tray();
}
if (view == "cut") intersection() {
    union() { electronics(); keys_and_knobs(); color([0.92, 0.92, 0.9]) top_shell(); color([0.75, 0.75, 0.75]) tray(); }
    translate([-10, 180 - 35 - 200, -50]) cube([400, 200, 120]);      // section through the Pi fan intake (board y = 35)
}
if (view == "pi") { electronics(); }
