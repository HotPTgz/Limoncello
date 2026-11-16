// Flush-key test piece for the 4-key HE test board (87 x 42 mm).
// Same heights as the v3 case: top surface 27 mm above the PCB, 2.5 mm panel, tiles from lmn3_v3_case.scad.
// It stands on the test board's printed switch plate (plate top 5 mm above the PCB) and shares its M2 screws.
// Each opening has a different gap so you can pick the one that feels best (key 1 tightest).
//
// render:  openscad -D 'part="none"' -D 'test_part="panel"' -o flush_test_panel.stl flush_test.scad
// test_part: panel | tile_white | tile_black | tile_menu | tiles_all | view
include <lmn3_v3_case.scad>
test_part = "view";

TW = 87; TD = 42; TU = 19.05; TKY = 14.0;
TEST_GAPS = [0.35, 0.45, 0.55, 0.65];
THOLES = [[3.5, 3.5], [TW - 3.5, 3.5], [3.5, TD - 3.5], [TW - 3.5, TD - 3.5]];
function tk(i) = [TW / 2 + TU * (i - 1.5), TD - TKY];      // OpenSCAD coords (test board y flipped)
function th(h) = [h[0], TD - h[1]];

module test_panel() {
    difference() {
        union() {
            translate([0, 0, Z_TOP - PANEL_T]) linear_extrude(PANEL_T) rrect(0, 0, TW, TD, 2);
            for (h = THOLES) translate(th(h)) translate([0, 0, PLATE_TOP]) cylinder(d = 6, h = Z_TOP - PLATE_TOP - 0.01);
        }
        for (i = [0:3]) translate(tk(i)) translate([0, 0, Z_TOP - PANEL_T - 1])
            linear_extrude(PANEL_T + 2) offset(1) square(CROWN + 2 * TEST_GAPS[i] - 2, center = true);
        for (h = THOLES) translate(th(h)) {
            translate([0, 0, PLATE_TOP - 1]) cylinder(d = 2.4, h = 40, $fn = 16);
            translate([0, 0, Z_TOP - 2]) cylinder(d = 4.4, h = 3, $fn = 20);           // M2 head
        }
        for (i = [0:3]) translate(tk(i)) translate([0, -11.5, Z_TOP - 0.5])          // gap labels engraved in the top
            linear_extrude(1) text(str(TEST_GAPS[i]), size = 2.6, halign = "center", valign = "center", font = "Liberation Sans:style=Bold");
    }
}
if (test_part == "panel")      translate([0, 0, Z_TOP]) mirror([0, 0, 1]) test_panel();   // top on the bed
if (test_part == "tile_white") tile_print(1, "");
if (test_part == "tile_black") tile_print(2, "");
if (test_part == "tile_menu")  tile_print(0, "REC");
if (test_part == "tiles_all") {   // 2 white, 1 black (raised), 1 labelled menu tile
    tile_print(1, ""); translate([21, 0, 0]) tile_print(1, "");
    translate([42, 0, 0]) tile_print(2, ""); translate([63, 0, 0]) tile_print(0, "REC");
}
if (test_part == "view") {
    color([0.92, 0.92, 0.9]) test_panel();
    color("darkgreen") translate([0, 0, -PCB_T]) cube([TW, TD, PCB_T]);
    for (i = [0:3]) translate(tk(i)) color(i == 2 ? [0.12, 0.12, 0.12] : [0.97, 0.97, 0.97])
        tile(i == 2 ? Z_TOP + BLACK_UP : Z_TOP, i == 3 ? "REC" : "");
}
