// 3D-printable switch plate for the LMN-3 HE key test board (87 x 42 mm).
// MX geometry: plate top 5.0 mm above the PCB top -> 1.5 mm plate on 3.5 mm legs.
// Print flat, PLA/PETG, 0.2 mm layers, 100% infill for the plate area. Fasten with 4x M2x8 screws + nuts.
W = 87; D = 42; T = 1.5; LEG = 3.5;
CUT = 14.0;          // switch cutout; raise to 14.1 if the switches are too tight in your print
KY = 14.0; U = 19.05;
holes = [[3.5,3.5],[W-3.5,3.5],[3.5,D-3.5],[W-3.5,D-3.5]];
keys = [for (i=[0:3]) [W/2 + U*(i-1.5), KY]];
// PCB y runs downward; OpenSCAD y runs upward -> mirror y so the print matches the board seen from the top
function m(p) = [p[0], D - p[1]];
difference() {
  union() {
    translate([0,0,LEG]) linear_extrude(T) offset(r=2) offset(delta=-2) square([W, D]);
    for (h = holes) translate([m(h)[0], m(h)[1], 0]) cylinder(d=6, h=LEG, $fn=40);
  }
  for (k = keys) translate([m(k)[0]-CUT/2, m(k)[1]-CUT/2, -1]) cube([CUT, CUT, 20]);
  for (h = holes) translate([m(h)[0], m(h)[1], -1]) cylinder(d=2.4, h=20, $fn=24);
  // window for the 1x8 header J1 (pins stick up through the plate; jumper wires plug in from the top)
  translate([W/2-12, m([0,38.5])[1], -1]) cube([24, 8, 20]);
}
