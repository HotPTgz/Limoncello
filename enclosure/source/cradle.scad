// LMN-3 v3: power bank cradle.
// Holds a UGREEN Nexode 20000mAh 130W power bank (45.5 x 46 x 115 mm column) lying behind the case,
// plus a USB-PD -> 5.1 V 5 A converter board in a bay at its port end, right behind the Pi's USB-C.
// A wedge under the case's rear edge tilts the LMN-3 towards the player (TILT) and screws into two
// M3 heat-set inserts in the tray (CRADLE_INSERTS in lmn3_v3_case.scad).
//
// Coordinates: "case" = lmn3_v3_case.scad (z = 0 at the PCB top); "table" = z = 0 on the table.
//   openscad -D 'part="cradle"' -o cradle.stl cradle.scad      (print it as it stands: base on the bed)
//   openscad -D 'part="scene"'  ...                             (cradle + bank + case on the table)
include <lmn3_v3_case.scad>
part = "cradle";

TILT    = 8;        // degrees the LMN-3 leans towards you (3..12 work)
FOOT_H  = 3.0;      // how far the case's rubber feet stand out
GAP     = 10;       // air between the case's rear wall (cooler exhaust) and the cradle

BANK    = [115, 46, 45.5];   // UGREEN Nexode 20000mAh 130W: length, width, thickness
BANK_CL = 0.8;               // clearance all round (snug: it slides in from the left end)
BAY     = [68, 47, 30];      // converter bay inside: fits boards up to ~64 x 46 mm (RDv5 62 x 25, 59 x 44 modules)
W       = 2.5;               // walls
TONGUE  = 4;                 // plate under the case
TONGUE_Y0 = 140;             // case Y where the wedge starts (case rear outer edge is Y1)
CX0     = 60;                // left end of the cradle (case X)

$fn = 40;
ZB = FLOOR_Z - FLOOR_T;      // case bottom
ZF = ZB - FOOT_H;            // rubber feet on the table

// the case on the table: tilted about its front feet
module case_pose() translate([0, 12, 0]) rotate([TILT, 0, 0]) translate([0, -12, -ZF]) children();
function pose(p) = [p[0], 12 + (p[1] - 12) * cos(TILT) - (p[2] - ZF) * sin(TILT),
                    (p[1] - 12) * sin(TILT) + (p[2] - ZF) * cos(TILT)];

REAR = pose([0, Y1, ZB]);                      // case rear bottom edge, on the table
IN   = [BANK[0] + 2 * BANK_CL, BANK[1] + 2 * BANK_CL, BANK[2] + 2 * BANK_CL];
YS0  = REAR[1] + GAP;                          // sleeve front face
SD   = IN[1] + 2 * W;                          // sleeve depth
SH   = IN[2] + 2 * W;                          // sleeve height
XD   = CX0 + IN[0];                            // divider
XB0  = XD + 3;  XB1 = XB0 + BAY[0];            // converter bay
CX1  = XB1 + W;

module rbox(p0, s, r = 2) translate(p0 + [r, r, 0]) linear_extrude(s[2]) offset(r) square([s[0] - 2 * r, s[1] - 2 * r]);

module wedge() {
    // the part under the case: its top is the case's bottom, its base sits on the table
    hull() {
        case_pose() translate([CX0, TONGUE_Y0, ZB - TONGUE]) cube([CX1 - CX0, Y1 - TONGUE_Y0, TONGUE]);
        translate([CX0, pose([0, TONGUE_Y0, ZB - TONGUE])[1], 0]) cube([CX1 - CX0, REAR[1] - pose([0, TONGUE_Y0, ZB - TONGUE])[1], 0.01]);
    }
    // bridge to the sleeve, low enough to leave the rear vents open
    translate([CX0, REAR[1] - 2, 0]) cube([CX1 - CX0, GAP + 4, 14]);
}

module sleeve() rbox([CX0, YS0, 0], [CX1 - CX0, SD, SH], 3);

module cradle() {
    difference() {
        union() { wedge(); sleeve(); }
        // the bank, sliding in from the left end
        translate([CX0 - 1, YS0 + W, W]) cube([IN[0] + 1, IN[1], IN[2]]);
        // finger notches at the left end, to pull the bank out
        for (z = [-1, SH - 9]) translate([CX0 - 1, YS0 + SD / 2 - 15, z]) cube([12, 30, 10]);
        // window over the bank: turn it display-up to read volts, amps and battery left
        translate([CX0 + 18, YS0 + W + 6, SH - W - 1]) rbox([0, 0, 0], [80, IN[1] - 12, W + 2], 4);
        // vents on the back
        for (i = [0:6]) translate([CX0 + 14 + i * 14, YS0 + SD - W - 1, 10]) cube([7, W + 2, SH - 20]);
        // cable passage from the bank's ports into the bay
        translate([XD - 1, YS0 + SD / 2 - 17, SH / 2 - 12]) cube([5, 34, 24]);
        // converter bay (open on top)
        translate([XB0, YS0 + W, W]) cube([BAY[0], BAY[1], SH]);
        // output cable notch towards the case's USB-C (PI_USBC_X)
        translate([PI_USBC_X - 9, YS0 - 1, SH - 16]) cube([18, W + 2, 17]);
        // bay vents underneath
        for (i = [0:4]) translate([XB0 + 8 + i * 12, YS0 + W + 8, -1]) cube([5, BAY[1] - 16, W + 2]);
        // screws into the tray inserts: M3 x 10 from below, through long access holes
        for (p = CRADLE_INSERTS) case_pose() translate([p[0], 180 - p[1], ZB - TONGUE - 80]) {
            cylinder(d = 3.4, h = 81);
            cylinder(d = 7, h = 80);
        }
        // rubber feet (10 mm), under the four corners
        for (x = [CX0 + 10, CX1 - 10], y = [pose([0, TONGUE_Y0, ZB - TONGUE])[1] + 9, YS0 + SD - 10])
            translate([x, y, -0.01]) cylinder(d = 10.5, h = 1.2);
    }
}

// stand-ins for the scene
module bank() {
    color([0.25, 0.27, 0.3]) translate([CX0 + BANK_CL, YS0 + W + BANK_CL, W + BANK_CL]) rbox([0, 0, 0], BANK, 6);
    color([0.1, 0.12, 0.15]) translate([CX0 + 20, YS0 + W + 10, W + BANK_CL + BANK[2] - 0.2]) cube([70, 28, 0.4]);   // display
}
module converter() color([0.1, 0.35, 0.6]) translate([XB0 + 3, YS0 + W + 1, W + 2]) cube([62, 25, 12]);

if (part == "cradle") cradle();
if (part == "scene") {
    color([0.85, 0.75, 0.55]) translate([X0 - 40, -60, -2]) cube([X1 - X0 + 80, 380, 2]);   // table
    color([0.95, 0.6, 0.25]) cradle();
    bank(); converter();
    case_pose() { pcb_dummy(); color([0.92, 0.92, 0.9]) top_shell(); color([0.75, 0.75, 0.75]) tray(); plate();
        for (k = KEYS) at([k[1], k[2]]) color(k[3] == 2 ? [0.12, 0.12, 0.12] : [0.97, 0.97, 0.97]) tile(k[3] == 2 ? Z_TOP + BLACK_UP : Z_TOP, k[4]);
        for (e = ENCODERS) at(e) color([0.2, 0.2, 0.2]) knob(); }
}
// clash check: the case (posed) against the cradle
if (part == "check_case") case_pose() union() { top_shell(); tray(); }
if (part == "check_cradle") cradle();
