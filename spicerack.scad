// New version.
// Vertical elements are now cut horizontally from the raw
// board. This way the racks height can differ from the raw
// boards height.

// This attempts to be a "Gewürzregal" (spice rack).
// I will try to only use one 4mm thick 30x60cm MDF board.

// Size of common spice containers (germany):
// Leng | Heig | Name
//   43     81   "Ostmann" small white cylindrical
//   56     78   "Fuchs" big white cylindrical
//   68    115   "HOREKA" smallish transparent (200ml?)
//   70     80   "Rinderbrühe" glass cylindrical

use <laser3d.scad>;
$play = 0.05;

// dimensions of raw board
width = 595;
height = 295;
thickness = 4.22;

board_count = 4;
rack_height = 420;
rack_depth = 70;

board_depth = 42;
board_offset = 105;
board_first = 5;

bar_offset = 7;
bar_height = 12;
bar_depth = 56 + 2*thickness + 3;

// teeth counts
board_side_tcount = 4;
board_back_tcount = 3;
side_back_tcount = 20;

sb_size = 50;

bpos = [for (i = [0:board_count-1]) i * board_offset + board_first];

module board() {
	difference() {
		square([height, board_depth-$play]);

		// intersection with side piece
		translate([thickness, thickness, 0]) rotate([0, 0, 90])
			teeth(board_depth-thickness, thickness, board_side_tcount);
		translate([height, thickness, 0]) rotate([0, 0, 90])
			teeth(board_depth-thickness, thickness, board_side_tcount);

		// intersection with sideback piece
		translate([thickness, 0, 0])
			teeth(sb_size-thickness, thickness, board_back_tcount);
		translate([height-thickness, thickness, 0]) rotate([0, 0, 180])
			teeth(sb_size-thickness, thickness, board_back_tcount);

		// remove small part used for intersection of side and sideback
		translate([0, 0, 0])
			square([thickness, thickness]);
		translate([height-thickness, 0, 0])
			square([thickness, thickness]);
	}
}

module side() {
	difference() {
		sideShape();
		teeth(rack_height, thickness, side_back_tcount);

		for (bp = [for (i = [0:board_count-1]) i * board_offset + board_first]) {
			translate([thickness+bp, thickness, 0]) rotate([0, 0, 90])
				teeth(board_depth-thickness, thickness, board_side_tcount, 1);
			translate([bp+thickness+bar_offset, bar_depth-thickness, 0])
				square([bar_height, thickness]);
		}

		// remove safety hazard
		translate([rack_height-29.7, 47])
			square([50, 50]);
	}
}

module sideback() {
	difference() {
		square([rack_height, sb_size]);
		teeth(rack_height, thickness, side_back_tcount, 1);

		// intersections with boards
		for (bp = [for (i = [0:board_count-1]) i * board_offset + board_first])
			translate([thickness+bp, thickness, 0]) rotate([0, 0, 90])
				teeth(sb_size-thickness, thickness, board_back_tcount, 1);

		// mounting holes
		for (i = [25:20:rack_height])
			translate([i, sb_size*2/3, 0]) circle(d = 5, $fn = 64);
	}
}

module bar() {
	square([height, bar_height-$play]);
}

module sideShape() {
	length = rack_height;
	period = rack_height / board_count;
	phase = 12;
	mean = 62;
	amplitude = 15;
	count = 100;

	polygon(concat([[length, 0], [0, 0]], [for (i = [0:count])
		[i / count * length,
		mean + amplitude * sin(phase + i/count*length/period*360)
	]]));
}

*union() {
	for (bp = [for (i = [0:board_count-1]) i * board_offset + board_first])
		translate([0, 0, bp]) linear_extrude(thickness) board();
	for (bp = [for (i = [0:board_count-1]) i * board_offset + board_first])
		translate([0, bar_depth, bp+thickness+bar_offset])
			rotate([90, 0, 0]) linear_extrude(thickness) bar();

	translate([thickness, 0, 0]) rotate([0, 270, 0])
		linear_extrude(thickness) side();
	translate([height, 0, 0]) rotate([0, 270, 0])
		linear_extrude(thickness) side();

	rotate([270, 270, 0])
		linear_extrude(thickness) sideback();
	translate([height, thickness, 0]) rotate([90, 270, 0])
		linear_extrude(thickness) sideback();
}

//%translate([150, 30, bpos[0]+thickness+0.1]) cylinder(78, r=56/2);
//%translate([50, 28, bpos[1]+thickness+0.1]) cylinder(81, r=43/2);

union() {
	offset0 = 0;

	offset1 = 0;

	for (i = [0:board_count-1])
		translate([0, offset1 + i * board_depth, 0]) board();
	offset2 = offset1 + board_count * board_depth;

	for (i = [1:board_count])
		translate([i * bar_height, offset2, 0])
			rotate([0, 0, 90]) bar();
	offsetX = board_count * bar_height;

	for (i = [1:2])
		translate([offsetX + i*(sb_size+$play), offset2, 0])
			rotate([0, 0, 90]) sideback();

	translate([height, offset2, 0])
		rotate([0, 0, 90]) side();
	translate([height - 140, offset2 + rack_height, 0])
		rotate([0, 0, -90]) side();
}

