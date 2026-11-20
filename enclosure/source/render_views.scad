include <lmn3_v3_case.scad>
view = "open";
if (view == "open") assembly();
if (view == "lid") { assembly(); color([0.55, 0.65, 0.75], 0.95) lid_mag(); }
if (view == "section") intersection() { assembly(); translate([-10, 180 - 160, -40]) cube([400, 200, 100]); }
if (view == "caps") assembly(true);
if (view == "caps_section") intersection() { assembly(true); translate([-10, 180 - 175, -40]) cube([400, 33, 100]); }
