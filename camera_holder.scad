// letter_size = 10;
// plate_depth = letter_size * 2;
// letter_height = 5;
// handle_height = 12;
// handle_width = 4;
// plate_width = 75;
// 
// 
// translate([0,0,0]) cube([plate_width,plate_depth,2]);
// linear_extrude(letter_height)
// translate([letter_size / 2, letter_size / 2,0]) text( "Stolworthy", size= letter_size);
// translate([0,plate_depth / 2 - handle_width / 2,-handle_height]) cube([75,handle_width,handle_height]);
// translate([plate_width/2 - handle_width / 2,0,-handle_height]) cube([handle_width, plate_depth, handle_height]);
// 
//

wall_thickness=2.5;
ledge_size = 2;

bar_thickness = 21.5;

camera_back_thickness = 29;
camera_front_thickness = 33;
camera_max_thickness = max(camera_back_thickness, camera_front_thickness);
camera_depth = 34;
camera_width = 107;
camera_holder_depth = camera_depth + wall_thickness * 2;
camera_holder_height = camera_max_thickness + wall_thickness;


holder_depth = bar_thickness + wall_thickness * 2;
holder_height = bar_thickness + (wall_thickness * 3) + camera_max_thickness;
holder_width = camera_width;
holder_opening_height = bar_thickness - ledge_size * 2;

fork_size = 15;

camera_bar_depth_delta = camera_depth - bar_thickness;

module fork_exclusion() {
    translate([fork_size, wall_thickness, 0]) {
        cube([holder_width - fork_size * 2, camera_depth + wall_thickness, camera_max_thickness]);
    }
}

module bar_exclusion() {
    union() {
        translate([0,wall_thickness,holder_height - bar_thickness - wall_thickness]) {
            cube([holder_width,bar_thickness,bar_thickness]);
            translate([0, bar_thickness, ledge_size]) {
                cube([holder_width, wall_thickness, holder_opening_height]);
                
            }
        }
    }
}

module camera_exclusion() {
    union() {
        translate([0, wall_thickness, wall_thickness]) {
            cube([holder_width, camera_depth, camera_max_thickness]);
            translate([0, camera_depth, ledge_size]) {
                cube([holder_width, wall_thickness, camera_front_thickness - ledge_size * 2]);
            }
        }
    }
}

module base_cube() {
    union() {
        translate([0, camera_bar_depth_delta, 0]) {
            cube([holder_width,holder_depth,holder_height]);
        }
        cube([holder_width, camera_holder_depth, camera_holder_height + wall_thickness]);
    }
}

difference() {
    base_cube();
    
    camera_exclusion();

    translate([0, camera_bar_depth_delta, 0]) {
        bar_exclusion();
    }
    // Camera bottom fork exclusion
    fork_exclusion();
}


