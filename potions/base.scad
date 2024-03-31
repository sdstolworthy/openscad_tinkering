upper_bowl_back_lip = 3;
marble_size = 16.8;
marble_scale_factor = 1.28;
adjusted_marble_size = marble_size * marble_scale_factor;
lower_depth = 140;
upper_depth = 128;
upper_ramp = 38.2;
lower_ramp = 14.5;
upper_bowl_height = 4;
upper_plate_thickness = 3;
channel_radius = adjusted_marble_size / 2;
upper_height = upper_ramp - channel_radius + adjusted_marble_size + upper_plate_thickness + upper_bowl_height;
plate_height = upper_height - upper_bowl_height - upper_plate_thickness;
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

module ramp(x, y, z) {
  polyhedron(points = [
    [0, 0, 0],
    [0, y , 0],
    [x, y , 0],
    [x, 0, 0],
    [0, 0, z],
    [x, 0, z]
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

module inner_upper_deck(height = deck_difference, z = lower_height) {
  translate([wall, wall, z]) deck(upper_depth - wall * 2, width - wall * 2, height);
}

module upper_plate() {
  difference() {
    inner_upper_deck(upper_plate_thickness, z = 0);
    for (x = [0:4]) {
      x_offset = getChannelSpacing(x);
      translate([x_offset - channel_radius, wall + upper_bowl_back_lip, 0]) cube([channel_radius * 2, channel_radius * 2, upper_plate_thickness]);
    }
    translate([width / 2 + 42, upper_depth / 2, 1]) linear_extrude(upper_plate_thickness) rotate(180) text("Potion Explosion", size = 10, font = "Z003");
  }
}

module stud(width = 5, depth = 1, height = 4) {
  translate([0, 0, height]) rotate(-90,[1,0,0]) ramp(width, height, depth);
}

module studs() {
  height = 4;
  depth = 1;
  side_width = upper_depth - 20;
  
  color("green") translate([ wall, upper_depth - wall - side_width - corner_radius, plate_height - height]) rotate(90) mirror([0,1,0]) stud(depth=depth, height=height, width = side_width);
  color("green") translate([width - wall, upper_depth - wall - side_width - corner_radius, plate_height - height]) rotate(90) stud(depth=depth, height=height, width = side_width);
  color("green") translate([wall + corner_radius, wall , plate_height - height]) stud(depth=depth, height=height, width = width - wall * 2 - corner_radius * 2);
  color("green") translate([wall + corner_radius, upper_depth - wall, plate_height - height]) mirror([0,1,0]) stud(depth=depth, height=height, width = width - wall * 2 - corner_radius * 2);
}

module full_base() {
  difference() {
    union() {
      difference() {
        union() {
          lower_deck();
          upper_deck();
        }
        inner_lower_deck(lower_height + 1);
        inner_upper_deck();
      }
      translate([wall, wall, lower_ramp]) ramp(width - wall * 2, total_depth - wall, ramp_delta);

      difference() {
        union() {
          inner_lower_deck(lower_ramp);
        }
      }
      *translate([0,0,plate_height]) upper_plate();
      *translate([-200,0,0]) upper_plate();
      studs();
    }
    channels();
  }
}

module locking_mechanism() {
  translate([wall + 3, upper_depth + 0.5, 0]) rotate(30) cylinder(r=4, h = lower_height - 12, $fn = 3);
  translate([width - wall - 3, upper_depth + 0.5, 0]) rotate(30) cylinder(r=4, h = lower_height - 12, $fn = 3);
}

module inverse_ramp() {
  ramp_height = lower_depth * tan(90 - beta);
  ramp_offset = 4;
  translate([0, upper_depth + lower_depth, lower_height - ramp_offset])
  color("red")
  union() {
    rotate(180, [1,0,0]) ramp(width, lower_depth + wall, ramp_height);
    translate([0,-lower_depth,0])
    cube([width, lower_depth, deck_difference]);
  }
}

module lower_base() {
  translate([0, -upper_depth, 0]) difference() {
    difference() {
      full_base();
      inverse_ramp();
      translate([0, 0, 0]) cube([width, upper_depth, upper_height + 5]);
    }
    locking_mechanism();
  }
}
module upper_base() {
  union() {
    difference() {
      full_base();
      translate([0, upper_depth + 0.01, 0]) cube([width, lower_depth, upper_height + 5]);
    }
    locking_mechanism();
  }
}


upper_base();
