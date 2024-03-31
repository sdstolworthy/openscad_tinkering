wall_thickness = 2;
tray_width = 144;
upper_tray_depth = 128;
lower_tray_depth = 140;
lower_tray_height_min = 35;
upper_tray_height = 65;
upper_ramp_height = 56;
lower_ramp_height = 19.5;
ramp_delta_height = upper_ramp_height - lower_ramp_height;
total_tray_depth = upper_tray_depth + lower_tray_depth;
ramp_hypotenuse = sqrt(ramp_delta_height ^ 2 + total_tray_depth ^ 2);
ramp_angle = atan(total_tray_depth/ramp_delta_height);
cylinder_radius = 25 / 2;
echo(ramp_delta_height);
echo(ramp_angle);
ramp_max = upper_ramp_height + lower_ramp_height - wall_thickness;

difference() {
  translate([0, 0, lower_ramp_height]) {
    rotate([90,0,90]){
      linear_extrude(tray_width - wall_thickness * 2) {
        polygon([
          [wall_thickness,wall_thickness],
          [wall_thickness, upper_ramp_height - wall_thickness],
          [upper_tray_depth+lower_tray_depth - wall_thickness, wall_thickness]
        ]);
      }
    }
  }
}

module marble_channel() {
  rotate([270,0,180-ramp_angle]) {
    cylinder(ramp_hypotenuse, cylinder_radius, cylinder_radius);
  }
}

marble_channel();


// rotate([ramp_angle,0,0]) {
//   translate([cylinder_radius,  lower_ramp_height * 2, -total_tray_depth]) {
//       cylinder(ramp_hypotenuse, cylinder_radius, cylinder_radius);
//   }
// }
// difference() {
//   union() {
//     cube([144,128,65]);
//     translate([0,128,0]){
//       cube([144,140,35]);
//     }
//   }
// }
