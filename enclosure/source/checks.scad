// interference checks: every test should render EMPTY
include <lmn3_v3_case.scad>
test = "";
module screen_mod() screen_model();
module speakers_v() for (s = SPEAKERS) at(s) translate([0,0,4.5]) cylinder(d = 40, h = Z_TOP - PANEL_T - 4.5 - 0.05);
module encoders_v() for (e = ENCODERS) at(e) { translate([-6,-6,0]) cube([12,12,6.5]); cylinder(d = 6, h = ENC_SHAFT_TOP); }
module joystick_v() at(JOYSTICK) { translate([-9.8,-12.3,0]) cube([19.6,24.6,12]); cylinder(d = 8, h = Z_TOP + 5); }
module mic_v() at(MIC) cylinder(d = 6, h = 4.9);
module jack_v() translate([311.2, T([0,80.7])[1], 0]) cube([330.3-311.2, 80.7-71.5, 5.5]);
module tiles_at(dz) for (k = KEYS) at([k[1], k[2]]) translate([0,0,-dz]) tile(k[3] == 2 ? Z_TOP + BLACK_UP : Z_TOP, "");
module knobs_v() for (e = ENCODERS) at(e) knob();
// Pi 5 envelope from the official STEP (board coords): board + parts, port stack, rear ports overhanging the edge
module pi_v() {
    translate([112, T([0,57])[1], PI_BOT_Z + 0.02]) cube([85, 56, -PCB_T - PI_BOT_Z - 0.02]);
    translate([108.1, T([0,55.7])[1], PI_BOT_Z + 0.02]) cube([21.4, 54.8, 3.6 - PI_BOT_Z]);    // USB/Ethernet stack, up through the opening
    for (p = [[180.3, 190.3, -12.5, -9.3], [167.6, 175.3, -12.82, -9.23], [153.0, 161.4, -12.82, -9.23]])
        translate([p[0], T([0, 1])[1], p[2]]) cube([p[1] - p[0], 1.63, p[3] - p[2]]);   // USB-C, 2 x micro-HDMI overhang
}
module codec_v() translate([205, T([0,42])[1], -24]) cube([65, 31, 22.4]);
module teensy_v() translate([30, T([0,88.5])[1], -12]) cube([61.1, 17.9, 10.4]);
module pcb_v() translate([0,0,-PCB_T]) linear_extrude(PCB_T) offset(3) offset(-3) square([330,180]);   // board corners are R3
if (test == "g_top") top_shell();
if (test == "g_tray") tray();
if (test == "g_plate") plate();
if (test == "g_tiles0") tiles_at(0);
if (test == "g_tiles1") tiles_at(TRAVEL);
if (test == "g_knobs") knobs_v();
if (test == "g_parts_top") union() { pi_v(); screen_mod(); speakers_v(); encoders_v(); joystick_v(); mic_v(); jack_v(); pcb_v(); }
if (test == "g_parts_low") union() { pi_v(); codec_v(); teensy_v(); pcb_v(); }
if (test == "g_switches") for (k = KEYS) at([k[1], k[2]]) difference() { translate([-7,-7,0]) cube([14,14,11.6]); translate([0,0,7]) cylinder(d = 7.5, h = 10); }
if (test == "g_plate_parts") union() { encoders_v(); joystick_v(); mic_v(); }
if (test == "g_p_screen") screen_mod();
if (test == "g_p_spk") speakers_v();
if (test == "g_p_enc") encoders_v();
if (test == "g_p_joy") joystick_v();
if (test == "g_p_mic") mic_v();
if (test == "g_p_jack") jack_v();
if (test == "g_p_pcb") pcb_v();
if (test == "g_lidslide") lid_slide();
if (test == "g_lidmag") lid_mag();
if (test == "g_highest") union() { knobs_v(); tiles_at(0); joystick_v(); }
if (test == "g_cooler") translate([133, T([0, 50])[1], -12.6]) cube([63.5, 42.5, 10.5]);
if (test == "g_screen") screen_mod();
if (test == "g_pcbreal") translate([0,0,-PCB_T]) linear_extrude(PCB_T) difference() { square([330,180]); translate(T([0, 0])) mirror([0, 1]) polygon(PCB_OPENING); }
// option B: keycaps in a sunken well
if (test == "g_top_caps") top_shell(true);
if (test == "g_deck") deck();
if (test == "g_caps0") caps_at(0);
if (test == "g_caps1") caps_at(TRAVEL);
if (test == "g_caps1_rings") for (k = KEYS) at([k[1], k[2]]) translate([0, 0, SEAT_Z - TRAVEL]) linear_extrude(CAP_H) difference() { cap_2d(k); square(15.6, center = true); }
