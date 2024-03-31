marble_size = 16.8;
marble_scale_factor = 1.5;
adjusted_marble_size = marble_size * marble_scale_factor;
lower_depth = 140;
upper_depth = 128;
upper_ramp = 38.2;
lower_ramp = 14.5;
upper_bowl_height = 4;
upper_plate_thickness = 3;
channel_radius = adjusted_marble_size / 2;
upper_height = upper_ramp - channel_radius + adjusted_marble_size + upper_plate_thickness + upper_bowl_height;
lower_height = 26;
deck_difference = upper_height - lower_height;
total_depth = lower_depth + upper_depth;
wall = 2.8;
corner_radius = 3;
channel_spacing = 1.2;
channel_count = 5;
width = channel_radius * 2 * channel_count + channel_spacing * (channel_count + 1) + wall * 2;
inner_depth = total_depth - wall * 2;
ramp_delta = upper_ramp - lower_ramp;

beta = atan(inner_depth / ramp_delta);

module deck(depth, width, height, radius = corner_radius) {
  translate([radius, radius, 0]) {
    hull() {
      for (x = [0, width - radius * 2]) {
        for (y = [0, depth - radius * 2]) {
          translate([x, y, 0]) {
            cylinder(h = height, r = radius, center = false, $fn = 100);
          }
        }
      }
    }
  }
}

function getChannelSpacing(number) = 
  wall + channel_radius + (number * 2 * channel_radius) + channel_spacing + channel_spacing * number;


module channel(channel_number) {
  x_offset = getChannelSpacing(channel_number);
  translate([x_offset, wall, upper_ramp]){
    rotate(180 - beta, [-1,0,0]) {
      cylinder(r=channel_radius, h = 250, $fn = 100);
    }
  }
}

module ramp() {
  polyhedron(points = [
    [wall, wall, lower_ramp],
    [wall, total_depth , lower_ramp],
    [width - wall, total_depth , lower_ramp],
    [width - wall, wall, lower_ramp],
    [wall, wall, upper_ramp],
    [width - wall, wall, upper_ramp]
  ], faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]);
}

module channels() {
  for (x_index = [0:4]) {
    channel(x_index);
  }
}

module lower_deck(height = lower_height) {
  // base deck
 deck(total_depth, width, height);
}

module upper_deck() {
  // upper deck
 translate([0,0,lower_height]) deck(upper_depth, width, deck_difference);
}

module inner_lower_deck(height = lower_height) {
  translate([wall, wall, wall]) deck(total_depth - wall * 2, width - wall * 2, height - wall);
}

module inner_upper_deck(height = deck_difference) {
  translate([wall, wall, lower_height]) deck(upper_depth - wall * 2, width - wall * 2, height);
}


difference() {
  union() {
    difference() {
      union() {
        lower_deck();
        upper_deck();
        ramp();
      }
      inner_lower_deck(lower_height + 1);
      inner_upper_deck();
    }

    color("blue") difference() {
      union() {
        ramp();
        inner_lower_deck(lower_ramp);
      }
    }

    difference() {
      color("green") translate([0,0,upper_height - upper_bowl_height - upper_plate_thickness - lower_height]) inner_upper_deck(upper_plate_thickness);
      for (x = [0:4]) {
        x_offset = getChannelSpacing(x);
        translate([x_offset - channel_radius, wall + channel_spacing, 0]) cube([channel_radius * 2, channel_radius * 2, 100]);
      }
    }
  }
  #channels();
  translate([width / 2 + 42, upper_depth / 2, 20 + lower_height + 1]) linear_extrude(20) rotate(180) text("Potion Explosion", size = 10, font = "Z003");
}
