// LMN-3 v3 (rev C) enclosure, concept B: one flat top.
// Screen glass, speaker grilles and flat tile keys are flush with the top surface;
// black piano keys stand 1.5 mm proud. Bottom tray holds the Pi 5 + Codec Zero underneath.
// Units mm. z = 0 is the PCB top surface. Board coords: x right, y towards the player (front);
// OpenSCAD Y = 180 - board y (front edge at Y = 0).
//
// Render one part:  openscad -D 'part="top_left"' -o top_left.stl lmn3_v3_case.scad
// parts: top_left top_right tray_left tray_right plate_left plate_right
//        key_menu key_white key_black  keys_menu_all (22 labelled)  knob
//        lid_mag_left lid_mag_right lid_slide_left lid_slide_right  assembly
//        option B (piano-style MX keycaps): top_left_caps top_right_caps deck_left deck_right  assembly_caps
include <v3_layout.scad>

part = "assembly";

// ---------------- key heights (from the PCB top) ----------------
PCB_T     = 1.6;
GLASS_Z   = 26.0;        // screen front face; Waveshare's 3D model: 21.5 mm deep at the centre, 9.8 / 12.5 mm at the wings
LIP_T     = 1.0;         // top-panel lip over the glass border: protects the glass, glass sits 1 mm below
Z_TOP     = GLASS_Z + LIP_T;     // flat top surface = 27
PANEL_T   = 2.5;
BLACK_UP  = 1.5;         // black keys proud of the top
PLATE_TOP = 5.0;         // MX: plate top 5 mm above the PCB
PLATE_T   = 1.5;
SEAT_Z    = PLATE_TOP + 7.1;     // underside of the keycap stem socket at rest
TRAVEL    = 3.5;

// ---------------- tile keys ----------------
GAP       = 0.5;         // gap between a tile and its opening (per side); tune with the test piece
CROWN     = 16.4;        // part of the tile that passes through the top panel
OPENING   = CROWN + 2 * GAP;
LOW_W     = 18.0;        // wider lower body under the panel (hollow over the switch)
CAV_W     = 15.2;  CAV_D = 4.5;  // cavity that swallows the switch top at bottom-out
SHOULDER_CLR = 0.6;      // gap between the tile shoulder and the panel underside at rest

// ---------------- encoders / joystick ----------------
ENC_SHAFT_TOP = 20.0;    // EC11, 20 mm shaft measured from the PCB
// the 4 encoders sit in a sunken pocket so the knobs give a real grip but stay low for the lid
POCKET = [253, 81, 326, 129];    // board coords x0, y0, x1, y1
POCKET_DEPTH = 7;  POCKET_WALL = 1.6;  POCKET_FLOOR = 2.5;
FLOOR_TOP = Z_TOP - POCKET_DEPTH;        // 20
KNOB_D = 16; KNOB_GRIP = 12; KNOB_BORE = 6.0; KNOB_HOLE = KNOB_D + 2;
KNOB_TOP = FLOOR_TOP + KNOB_GRIP;        // 32 = 5 mm above the main top
KNOB_PROUD = KNOB_TOP - Z_TOP;
// ---------------- option B: piano-style MX keycaps instead of flush tiles ----------------
// For the "LMN-3 Key Caps" set (Thingiverse 5996834): 7 mm tall caps; white keys next to a
// missing black key have an 8.5 mm wide tongue reaching back into the black row.
// The caps would sit 8 mm below the flat top, so the key area becomes a sunken WELL with a
// separate DECK plate (printed face down, glued onto a ledge) at the level of the caps.
KEY_STYLE = "flush";     // default for the assembly view: "flush" or "caps"
CAP_W = 18.0;  CAP_H = 7.0;
CAP_TONGUE = 19.0;  CAP_TONGUE_W = 8.5;
CAP_GAP = 0.5;           // gap between the caps and the deck opening
DECK_TOP = 15.0;         // caps (top at SEAT_Z + CAP_H = 19.1) stand 4.1 mm proud; 0.6 mm at bottom-out
DECK_T = 2.5;
DECK_BOTTOM = DECK_TOP - DECK_T;
WELL_WALL = 1.6;  LEDGE_W = 1.5;  LEDGE_T = 2.0;  DECK_CLR = 0.25;
DECK_POSTS = [[95, 128.4], [130, 128.4], [205, 128.4], [240, 128.4]];   // deck -> switch plate, clear of the plate screws
JOY_HOLE = 27;           // opening for the thumb-joystick gimbal
JOY_PROUD = 8;           // how far the joystick cap stands above the top (for the lids)

// ---------------- shell ----------------
WALL = 3.0; CLR = 0.5; R_OUT = 6;
X0 = -WALL - CLR; X1 = 330 + CLR + WALL;
Y0 = -WALL - CLR; Y1 = 180 + CLR + WALL;
FLOOR_Z = -26.0;         // inside floor (Codec Zero terminal block reaches ~ -24)
FLOOR_T = 2.4;
SPLIT_X = 174.52;        // print split: a key-column boundary, passes through the screen window
SCREEN_WIN = [195, 63];  // glass window in the top (screen active area 191 x 60.4, assumed centred)
PI_USBC_X = 185.3;  PI_USBC_Z = -10.9; // Pi 5 USB-C on the rear wall (official Pi 5 STEP: board x 180.3-190.3, z -12.5..-9.3)
PI_HDMI_X = [171.45, 157.2];  PI_HDMI_Z = -11.0;   // the two micro-HDMI (STEP: x 167.6-175.3 / 153.0-161.4, z -12.8..-9.2)
// Pi 5 placement (from the official STEP): board x = 197 - Pi x, board y = 1 + Pi y; Pi top face z = -12.6, bottom z = -14.0
PI_BOT_Z = -13.92;   // Pi board underside (STEP board 1.28 thick, top face at z -12.6)
PI_POSTS = [[193.5, 4.5], [135.5, 4.5], [193.5, 53.5]];   // tray posts under 3 Pi mounting holes (the 4th, H12, is a PCB stand-off)
PI_SPACER = 6;   // M2.5 x 6 F-F stand-offs screwed under the Pi at those 3 holes; M2.5 x 8 screws from below into them
// power bank cradle (cradle.scad): screwed under the tray's rear edge with M3 into these heat-set inserts
CRADLE_INSERTS = [[70, 6], [225, 6]];   // board coords
// exact rear-edge opening of the rev C board (board coords)
PCB_OPENING = [[107.5, -1], [107.5, 56.5], [130.5, 56.5], [130.5, 50.3], [190.5, 50.3], [190.5, 14.5], [197.3, 14.5], [197.3, -1]];
MAG_D = 8.2; MAG_H = 3.2;            // 8 x 3 mm neodymium magnets
MAGNETS = [[20,4],[50,4],[280,4],[310,4],[40,176],[120,176],[210,176],[290,176]];   // board coords, clear of screen/speakers

$fn = 48;
// Waveshare 7.9" monitor, from Waveshare's own 3D model (7_9inch-side-monitor-case.stp), placed glass up.
// STEP (xs, ys, zs) -> board x = cx - xs, board y = cy - zs, z = GLASS_Z - 2.8 + ys  (ports end up facing +x)
module screen_model() {
    c = [(SCREEN[0] + SCREEN[2]) / 2, (SCREEN[1] + SCREEN[3]) / 2];
    translate([c[0], 180 - c[1], GLASS_Z - 2.8]) multmatrix([[-1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]]) import("screen_waveshare.stl");
}
SCREEN_PORT_X = (SCREEN[0] + SCREEN[2]) / 2 + 48.5;   // the screen's USB-C / HDMI / button openings face +x here
function T(p) = [p[0], 180 - p[1]];
module rrect(x0, y0, x1, y1, r) { translate([x0 + r, y0 + r]) offset(r) square([x1 - x0 - 2 * r, y1 - y0 - 2 * r]); }
module outline() { rrect(X0, Y0, X1, Y1, R_OUT); }
module inner()   { offset(-WALL) outline(); }
module at(p) { translate([T(p)[0], T(p)[1], 0]) children(); }
module sq(c, w) { translate([c[0] - w / 2, c[1] - w / 2]) square([w, w]); }

// =====================================================================  top shell
module grille(c) {        // round-hole speaker grille, 34 mm field
    for (i = [-6:6], j = [-6:6]) {
        x = i * 2.9 + (j % 2) * 1.45; y = j * 2.5;
        if (x * x + y * y < 16.5 * 16.5) translate([T(c)[0] + x, T(c)[1] + y]) circle(d = 1.8, $fn = 12);
    }
}
module top_openings(caps = false) {
    // screen window, centred on the module
    sc = [(SCREEN[0] + SCREEN[2]) / 2, (SCREEN[1] + SCREEN[3]) / 2];
    translate(T(sc)) offset(1) square([SCREEN_WIN[0] - 2, SCREEN_WIN[1] - 2], center = true);
    if (caps) well_2d();
    else {
        for (k = KEYS) translate(T([k[1], k[2]])) offset(1) square([OPENING - 2, OPENING - 2], center = true);
        pocket_2d();
    }
    translate(T(JOYSTICK)) circle(d = JOY_HOLE);
    for (s = SPEAKERS) grille(s);
    translate(T(MIC)) circle(d = 1.6, $fn = 16);
}
module pocket_2d() { rrect(POCKET[0], T([0, POCKET[3]])[1], POCKET[2], T([0, POCKET[1]])[1], 4); }
module pocket_body() {   // walls + floor of the sunken encoder pocket
    zb = FLOOR_TOP - POCKET_FLOOR;
    translate([0, 0, zb]) linear_extrude(Z_TOP - PANEL_T - zb + 0.01) difference() { offset(POCKET_WALL) pocket_2d(); pocket_2d(); }
    translate([0, 0, zb]) linear_extrude(POCKET_FLOOR) difference() {
        offset(POCKET_WALL) pocket_2d();
        for (e = ENCODERS) translate(T(e)) circle(d = KNOB_HOLE);
    }
}
// ---------------- option B geometry (board coords in, OpenSCAD coords out) ----------------
function keyx(t) = [for (k = KEYS) if (k[3] == t) k[1]];
function keyy(t) = [for (k = KEYS) if (k[3] == t) k[2]];
MENU_BLOCK  = [min(keyx(0)) - CAP_W / 2, min(keyy(0)) - CAP_W / 2, max(keyx(0)) + CAP_W / 2, max(keyy(0)) + CAP_W / 2];
PIANO_BLOCK = [min(keyx(1)) - CAP_W / 2, min(keyy(2)) - CAP_W / 2, max(keyx(1)) + CAP_W / 2, max(keyy(1)) + CAP_W / 2];
module bx(x0, y0, x1, y1) translate([x0, 180 - y1]) square([x1 - x0, y1 - y0]);
module well_2d() offset(r = 2) offset(delta = -2) offset(r = -3) offset(r = 3) union() {
    bx(MENU_BLOCK[0] - 3, MENU_BLOCK[1] - 2.5, MENU_BLOCK[2] + 6, PIANO_BLOCK[1] + 1);   // menu keys (+ strip)
    bx(PIANO_BLOCK[0] - 3, PIANO_BLOCK[1] - 3, PIANO_BLOCK[2] + 3, PIANO_BLOCK[3] + 2.5);
    bx(POCKET[0], POCKET[1] + 0.5, POCKET[2], POCKET[3]);                               // encoders
}
module deck_windows() {
    bx(MENU_BLOCK[0] - CAP_GAP, MENU_BLOCK[1] - CAP_GAP, MENU_BLOCK[2] + CAP_GAP, MENU_BLOCK[3] + CAP_GAP);
    bx(PIANO_BLOCK[0] - CAP_GAP, PIANO_BLOCK[1] - CAP_GAP, PIANO_BLOCK[2] + CAP_GAP, PIANO_BLOCK[3] + CAP_GAP);
    for (e = ENCODERS) translate(T(e)) circle(d = KNOB_HOLE);
}
module well_body() {   // the well's walls, from the panel down to the ledge the deck sits on
    translate([0, 0, DECK_BOTTOM - LEDGE_T]) linear_extrude(Z_TOP - PANEL_T - DECK_BOTTOM + LEDGE_T + 0.01)
        difference() { offset(WELL_WALL) well_2d(); well_2d(); }
    translate([0, 0, DECK_BOTTOM - LEDGE_T]) linear_extrude(LEDGE_T) difference() { well_2d(); offset(-LEDGE_W) well_2d(); }
}
module deck() {
    translate([0, 0, DECK_BOTTOM]) linear_extrude(DECK_T) difference() { offset(-DECK_CLR) well_2d(); deck_windows(); }
    for (p = DECK_POSTS) at(p) translate([0, 0, PLATE_TOP + 0.2]) cylinder(d = 4, h = DECK_BOTTOM - PLATE_TOP - 0.2 + 0.01);
}
// a keycap stand-in: white keys next to a missing black key get the tongue towards it
function has_black(x) = len([for (k = KEYS) if (k[3] == 2 && abs(k[1] - x) < 1) 1]) > 0;
module cap_2d(k) {
    offset(1) square(CAP_W - 2, center = true);
    if (k[3] == 1 && !has_black(k[1] - 9.525))   // tongue on the left, reaching back (-y board = +Y)
        translate([-CAP_W / 2, CAP_W / 2 - 0.4]) square([CAP_TONGUE_W, CAP_TONGUE + 0.4]);
    if (k[3] == 1 && !has_black(k[1] + 9.525))
        translate([CAP_W / 2 - CAP_TONGUE_W, CAP_W / 2 - 0.4]) square([CAP_TONGUE_W, CAP_TONGUE + 0.4]);
}
module caps_at(dz) for (k = KEYS) at([k[1], k[2]]) translate([0, 0, SEAT_Z - dz]) linear_extrude(CAP_H) cap_2d(k);

module top_shell(caps = false) {
    sc = [(SCREEN[0] + SCREEN[2]) / 2, (SCREEN[1] + SCREEN[3]) / 2];
    difference() {
        union() {
            // panel
            translate([0, 0, Z_TOP - PANEL_T]) linear_extrude(PANEL_T) difference() { outline(); top_openings(caps); }
            // walls down to the PCB underside
            translate([0, 0, -PCB_T]) linear_extrude(Z_TOP - PANEL_T + PCB_T + 0.01) difference() { outline(); inner(); }
            // screws: bosses from the panel down onto the PCB top (M3 heat-set inserts from below)
            for (h = HOLES_TOP) at(h) cylinder(d = 7.5, h = Z_TOP - 0.5);
            // screen: corner brackets that hold the module in place (cables can leave on any side)
            for (sx = [0, 1], sy = [0, 1]) {
                cx = sx ? SCREEN[2] : SCREEN[0]; cy = sy ? SCREEN[3] : SCREEN[1];
                at([cx, cy]) translate([0, 0, GLASS_Z - 12]) linear_extrude(12 + Z_TOP - GLASS_Z)
                    scale([sx ? -1 : 1, sy ? 1 : -1]) difference() {
                        translate([-3.5, -3.5]) square([16, 16]);
                        square([20, 20]);
                    }
            }
            // speakers: retaining rings under the grille (40 mm speaker flange)
            for (s = SPEAKERS) at(s) translate([0, 0, Z_TOP - PANEL_T - 5]) difference() {
                cylinder(d = 45, h = 5.01); translate([0, 0, -1]) cylinder(d = 40.3, h = 7); }   // press fit + glue
            if (caps) well_body(); else pocket_body();
            // mic: acoustic tube from the pinhole down to the capsule
            at(MIC) translate([0, 0, 5.6]) cylinder(d = 5, h = Z_TOP - 5.6 - 0.1);
            // magnet bosses for the magnetic lid
            for (m = MAGNETS) at(m) translate([0, 0, Z_TOP - PANEL_T - 4]) cylinder(d = 11, h = 4.01);
        }
        for (h = HOLES_TOP) at(h) translate([0, 0, -1]) cylinder(d = 4.2, h = 9);          // heat-set insert M3 x 5.7
        // pocket for the screen module: the glass sits 1 mm under the top, the lip covers its border
        translate([T([SCREEN[0], 0])[0] - 0.5, T([0, SCREEN[3]])[1] - 0.5, GLASS_Z - 14]) cube([SCREEN[2] - SCREEN[0] + 1, SCREEN[3] - SCREEN[1] + 1, 14]);
        at(MIC) translate([0, 0, 4]) cylinder(d = 2.6, h = Z_TOP);                          // tube bore
        at(MIC) translate([0, 0, 4]) cylinder(d = 7.4, h = 1.6);                            // capsule seat (6 mm)
        for (m = MAGNETS) at(m) translate([0, 0, Z_TOP - PANEL_T - 4.1]) cylinder(d = MAG_D, h = PANEL_T + 4.1 - 0.6);   // magnet glued in from below, 0.6 mm skin on top
        // keep the outer walls clear of the board edge connectors
        at(JACK) translate([5.5, 0, 2.6]) rotate([0, 90, 0]) cylinder(d = 7.5, h = 10);   // headphone jack
        slide_grooves();
        // keep the pocket clear (cuts the (285,86) screw boss down to the pocket floor)
        if (caps) translate([0, 0, DECK_BOTTOM]) linear_extrude(20) well_2d();   // the boss then also props up the deck
        else translate([0, 0, FLOOR_TOP]) linear_extrude(20) pocket_2d();
        // rear vents in the air space between the PCB and the screen (Pi cooler pokes up through the PCB here)
        for (x = [116:6:192]) translate([x, Y1 - WALL - 1, 0.8]) cube([3, WALL + 2, 4.2]);
        // print split: 1.75 mm filament dowels through the seam in the front and rear walls
        for (y = [Y0 + 1.5, Y1 - 1.5], z = [2, 12, 20]) translate([SPLIT_X, y, z]) rotate([0, 90, 0]) cylinder(d = 1.9, h = 16, center = true, $fn = 12);
    }
}
module slide_grooves() {   // rails for the slide-on lid: grooves along the front and rear walls
    for (y = [Y0, Y1]) translate([X0 - 1, y - 1.5, Z_TOP - 5]) cube([X1 - X0 + 2, 3, 2.2]);
}

// =====================================================================  bottom tray
module tray() {
    difference() {
        union() {
            translate([0, 0, FLOOR_Z - FLOOR_T]) linear_extrude(FLOOR_T) outline();
            translate([0, 0, FLOOR_Z - 0.01]) linear_extrude(-PCB_T - FLOOR_Z + 0.01) difference() { outline(); inner(); }
            // screw bosses under every board hole (M3 from below)
            for (h = HOLES_ALL) at(h) translate([0, 0, FLOOR_Z - 0.01]) cylinder(d = 7.5, h = -PCB_T - FLOOR_Z);
            // Pi 5 posts: M2.5 screw from below into the Pi's mounting holes
            for (p = PI_POSTS) at(p) translate([0, 0, FLOOR_Z - 0.01]) cylinder(d = 7, h = PI_BOT_Z - PI_SPACER - FLOOR_Z);
            // bosses for the power bank cradle's screws
            for (p = CRADLE_INSERTS) at(p) translate([0, 0, FLOOR_Z - 0.01]) cylinder(d = 7.5, h = 6.5);
        }
        for (p = CRADLE_INSERTS) at(p) {
            translate([0, 0, FLOOR_Z - FLOOR_T - 1]) cylinder(d = 3.4, h = 12);            // M3 from below
            translate([0, 0, FLOOR_Z + 0.5]) cylinder(d = 4.2, h = 7);                     // M3 x 5.7 insert, pressed in from inside
        }
        for (p = PI_POSTS) at(p) {
            translate([0, 0, FLOOR_Z - FLOOR_T - 1]) cylinder(d = 2.9, h = 40);           // M2.5 clearance
            translate([0, 0, FLOOR_Z - FLOOR_T - 1]) cylinder(d = 5.2, h = 3.6);          // screw head counterbore
        }
        for (h = HOLES_ALL) at(h) {
            translate([0, 0, FLOOR_Z - FLOOR_T - 1]) cylinder(d = 3.4, h = 40);
            translate([0, 0, FLOOR_Z - FLOOR_T - 1]) cylinder(d = 6.2, h = 4);          // screw head counterbore
        }
        // rear wall: Pi USB-C power and the two micro-HDMI ports (they overhang the Pi edge by 1.2-1.6 mm, into the wall)
        translate([PI_USBC_X - 7, Y1 - WALL - 1, PI_USBC_Z - 4.5]) cube([14, WALL + 2, 9]);
        for (x = PI_HDMI_X) translate([x - 6, Y1 - WALL - 1, PI_HDMI_Z - 4]) cube([12, WALL + 2, 8]);
        // rear vents beside the Pi (cooler exhaust), clear of the port openings
        for (x = [116:6:192]) if (abs(x + 1.5 - PI_USBC_X) > 9 && min([for (h = PI_HDMI_X) abs(x + 1.5 - h)]) > 8) translate([x, Y1 - WALL - 1, -22]) cube([3, WALL + 2, 14]);
        // ventilation under the Pi
        for (i = [0:7]) translate([122 + i * 9, T([0, 50])[1], FLOOR_Z - FLOOR_T - 1]) cube([4, 40, FLOOR_T + 2]);   // board y 10-50, clear of the Pi posts
        // rubber feet recesses
        for (p = [[15, 12], [315, 12], [15, 168], [315, 168]]) translate([p[0], p[1], FLOOR_Z - FLOOR_T - 1]) cylinder(d = 10.5, h = 1.6);
        for (y = [Y0 + 1.5, Y1 - 1.5], z = [-22, -12, -5]) translate([SPLIT_X, y, z]) rotate([0, 90, 0]) cylinder(d = 1.9, h = 16, center = true, $fn = 12);
    }
}

// =====================================================================  switch plate (printed, 1.5 mm)
module plate_2d() {
    difference() {
        translate([36, T([0, 172])[1]]) square([282, 172 - 88]);   // x 36..318, clear of the corner boss
        for (k = KEYS) translate(T([k[1], k[2]])) square([14, 14], center = true);
        for (e = ENCODERS) translate(T(e)) square([13.5, 16], center = true);
        translate(T([285, 86])) circle(d = 8.6);
        for (h = HOLES_PLATE) translate(T(h)) circle(d = 3.4);
    }
}
module plate() {
    translate([0, 0, PLATE_TOP - PLATE_T]) linear_extrude(PLATE_T) plate_2d();
    for (h = HOLES_PLATE) at(h) difference() {          // legs down to the PCB, screwed from below
        cylinder(d = 7, h = PLATE_TOP - PLATE_T + 0.01); translate([0, 0, -1]) cylinder(d = 2.6, h = 10); }
}

// =====================================================================  keys
module stem_socket(h) {   // MX cross socket
    difference() {
        cylinder(d = 5.6, h = h);
        translate([0, 0, -0.01]) { cube([4.15, 1.32, 2 * 3.9], center = true); cube([1.32, 4.15, 2 * 3.9], center = true); }
    }
}
module tile(top_z = Z_TOP, label = "") {
    // built at rest position, z measured from the PCB; printed upside down (top on the bed)
    sh = Z_TOP - PANEL_T - SHOULDER_CLR;     // shoulder height
    difference() {
        union() {
            translate([0, 0, SEAT_Z]) linear_extrude(sh - SEAT_Z) offset(1.2) square(LOW_W - 2.4, center = true);
            translate([0, 0, sh - 0.01]) linear_extrude(top_z - sh + 0.01) offset(1) square(CROWN - 2, center = true);
        }
        translate([0, 0, SEAT_Z - 0.01]) linear_extrude(CAV_D) offset(1) square(CAV_W - 2, center = true);
        if (label != "") translate([0, 0, top_z - 0.6]) linear_extrude(1)
            text(label, size = len(label) > 4 ? 2.6 : 3.4, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
    translate([0, 0, SEAT_Z]) stem_socket(CAV_D + 0.01);
}
module knob() {
    bottom = ENC_SHAFT_TOP - 7;                 // 7 mm on the knurled shaft
    difference() {
        translate([0, 0, bottom]) union() {
            cylinder(d = KNOB_D - 2, h = FLOOR_TOP - bottom);                  // stem through the pocket floor
            translate([0, 0, FLOOR_TOP - bottom]) cylinder(d = KNOB_D, h = KNOB_TOP - FLOOR_TOP - 0.8);
            translate([0, 0, KNOB_TOP - bottom - 0.8]) cylinder(d1 = KNOB_D, d2 = KNOB_D - 1.6, h = 0.8);
        }
        translate([0, 0, bottom - 1]) cylinder(d = KNOB_BORE, h = 8);
        for (a = [0:15:359]) rotate(a) translate([KNOB_D / 2 + 0.3, 0, FLOOR_TOP + 1]) cylinder(d = 1.4, h = KNOB_GRIP, $fn = 8);   // grip ribs
        translate([0, 0, KNOB_TOP - 0.6]) rotate([0, 0, 0]) translate([0, KNOB_D / 2 - 2.6, 0]) cylinder(d = 1.4, h = 1, $fn = 12);   // pointer dot
    }
}

// =====================================================================  lids
LID_CLR = JOY_PROUD + 2;     // inside height above the top surface
LID_T = 2.4;
module lid_mag() {
    difference() {
        union() {
            translate([0, 0, Z_TOP + LID_CLR]) linear_extrude(LID_T) outline();
            translate([0, 0, Z_TOP]) linear_extrude(LID_CLR + 0.01) difference() { outline(); offset(-3) outline(); }
            for (m = MAGNETS) at(m) translate([0, 0, Z_TOP]) cylinder(d = 11, h = LID_CLR);
        }
        for (m = MAGNETS) at(m) translate([0, 0, Z_TOP - 0.01]) cylinder(d = MAG_D, h = MAG_H);   // glued in flush
        }
}
module lid_slide() {   // slides on from the right; the lips run in the wall grooves
    W = Y1 - Y0;
    difference() {
        union() {
            translate([X0, Y0 - 2.6, Z_TOP + LID_CLR]) cube([X1 - X0, W + 5.2, LID_T]);
            for (s = [0, 1]) translate([X0, s ? Y1 + 0.4 : Y0 - 2.6, Z_TOP - 5.2]) cube([X1 - X0, 2.2, LID_CLR + 5.2 + 0.01]);
            for (s = [0, 1]) translate([X0, s ? Y1 - 1.0 : Y0 - 0.4, Z_TOP - 4.8]) cube([X1 - X0, 1.4, 1.6]);   // lips
            translate([X0, Y0 - 2.6, Z_TOP]) cube([2.4, W + 5.2, LID_CLR + 0.01]);                                // end stop
        }
    }
}

// =====================================================================  stand-ins for the assembly view
module pcb_dummy() {
    color("darkgreen") translate([0, 0, -PCB_T]) linear_extrude(PCB_T) difference() {
        translate([0, 0]) square([330, 180]);
        for (s = SPEAKERS) translate(T(s)) circle(r = 21);
        translate(T([0, 0])) mirror([0, 1]) polygon(PCB_OPENING);
    }
    color([0.15, 0.15, 0.18]) screen_model();
    color([0.05, 0.05, 0.08]) translate([(SCREEN[0] + SCREEN[2]) / 2 - 95.5, T([0, (SCREEN[1] + SCREEN[3]) / 2])[1] - 30.2, 25.95]) cube([191.08, 60.4, 0.1]);
    for (k = KEYS) at([k[1], k[2]]) color("white", 0.6) translate([-7, -7, 0]) cube([14, 14, 11.6]);
    for (s = SPEAKERS) at(s) color("gray") translate([0, 0, 4.5]) cylinder(d = 40, h = Z_TOP - PANEL_T - 4.5);
    color("silver") translate([112, T([0, 57])[1], PI_BOT_Z]) cube([85, 56, 1.4]);          // Pi 5 (hanging), official outline
    color([0.35, 0.35, 0.4]) translate([133, T([0, 50])[1], PI_BOT_Z + 1.4]) cube([63.5, 42.5, 10.5]);   // Active Cooler (drawing)
}

// =====================================================================  print layout + splitting
module left()  { intersection() { children(); translate([-50, -50, -100]) cube([SPLIT_X + 50, 300, 300]); } }
module right() { intersection() { children(); translate([SPLIT_X, -50, -100]) cube([300, 300, 300]); } }
module flip_top() { translate([0, 0, Z_TOP]) mirror([0, 0, 1]) children(); }          // top surface on the bed
module tile_print(t, lab) { mirror([0, 0, 1]) translate([0, 0, -(t == 2 ? Z_TOP + BLACK_UP : Z_TOP)]) tile(t == 2 ? Z_TOP + BLACK_UP : Z_TOP, lab); }

module assembly(caps = KEY_STYLE == "caps") {
    pcb_dummy();
    color([0.92, 0.92, 0.9]) top_shell(caps);
    color([0.75, 0.75, 0.75]) tray();
    color([0.3, 0.3, 0.3]) plate();
    if (caps) {
        color([0.88, 0.88, 0.86]) deck();
        for (k = KEYS) at([k[1], k[2]]) color(k[3] == 2 || k[4] == "MIC" ? [0.12, 0.12, 0.12] : [0.97, 0.97, 0.97])
            translate([0, 0, SEAT_Z]) linear_extrude(CAP_H) cap_2d(k);
    } else
    for (k = KEYS) at([k[1], k[2]]) color(k[3] == 2 ? [0.12, 0.12, 0.12] : [0.97, 0.97, 0.97]) tile(k[3] == 2 ? Z_TOP + BLACK_UP : Z_TOP, k[4]);
    for (e = ENCODERS) at(e) color([0.2, 0.2, 0.2]) knob();
}

if (part == "assembly") assembly();
else if (part == "assembly_caps") assembly(true);
else if (part == "top_left_caps")  flip_top() left() top_shell(true);
else if (part == "top_right_caps") flip_top() right() top_shell(true);
else if (part == "deck_left")  translate([0, 0, DECK_TOP]) mirror([0, 0, 1]) left() deck();     // top face on the bed, posts up
else if (part == "deck_right") translate([0, 0, DECK_TOP]) mirror([0, 0, 1]) right() deck();
else if (part == "top_left")    flip_top() left() top_shell();
else if (part == "top_right")   flip_top() right() top_shell();
else if (part == "tray_left")   translate([0, 0, -(FLOOR_Z - FLOOR_T)]) left() tray();
else if (part == "tray_right")  translate([0, 0, -(FLOOR_Z - FLOOR_T)]) right() tray();
else if (part == "plate_left")  translate([0, 0, PLATE_TOP]) mirror([0, 0, 1]) left() plate();     // plate face on the bed, legs up
else if (part == "plate_right") translate([0, 0, PLATE_TOP]) mirror([0, 0, 1]) right() plate();
else if (part == "key_menu")    tile_print(0, "");
else if (part == "key_white")   tile_print(1, "");
else if (part == "key_black")   tile_print(2, "");
else if (part == "keys_menu_all") for (i = [0:21]) translate([(i % 6) * 21, floor(i / 6) * 21, 0]) tile_print(0, KEYS[i][4]);
else if (part == "knob")        translate([0, 0, KNOB_TOP]) mirror([0, 0, 1]) knob();
else if (part == "lid_mag_left")    translate([0, 0, Z_TOP + LID_CLR + LID_T]) mirror([0, 0, 1]) left() lid_mag();
else if (part == "lid_mag_right")   translate([0, 0, Z_TOP + LID_CLR + LID_T]) mirror([0, 0, 1]) right() lid_mag();
else if (part == "lid_slide_left")  translate([0, 0, Z_TOP + LID_CLR + LID_T]) mirror([0, 0, 1]) left() lid_slide();
else if (part == "lid_slide_right") translate([0, 0, Z_TOP + LID_CLR + LID_T]) mirror([0, 0, 1]) right() lid_slide();
