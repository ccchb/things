// This attempts to be a "Gewürzregal" (spice rack).
// I will try to only use one 4mm thick 30x60cm MDF board.

// Size of common spice containers (germany):
// Leng | Heig | Name
//   43     81   "Ostmann" small white cylindrical
//   56     78   "Fuchs" big white cylindrical
//   68    115   "HOREKA" smallish transparent (200ml?)
//   70     80   "Rinderbrühe" glass cylindrical

// dimensions of raw board
width = 595;
height = 295;
thickness = 4.22;

board_depth = 90;
bar_offset = 7;
bar_height = 10;
//bpos = [5, 120, height - thickness - 5];
bpos = [5, 115, 265];

board_side_tcount = 4;
board_back_tcount = 4;
side_back_tcount = 20;

// calculate the size of the sideback pieces
used = board_depth * 5 + bar_height * len(bpos);
sb_size = (width - used) / 2;

module teeth(length, depth, count, start = 0) {
	size = length / count;
	for (i = [start:2:count])
		translate([i*size-0.001, -0.001, 0])
			square([size+0.002, depth+0.002]);
}

module board() {
	difference() {
		square([height, board_depth]);

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
		square([height, board_depth]);
		teeth(height, thickness, side_back_tcount);

		for (bp = bpos) {
			translate([thickness+bp, thickness, 0]) rotate([0, 0, 90])
				teeth(board_depth-thickness, thickness, board_side_tcount, 1);
			translate([bp+thickness+bar_offset, board_depth-thickness, 0])
				square([bar_height, thickness]);
		}
	}
}

module sideback() {
	difference() {
		square([height, sb_size]);
		teeth(height, thickness, side_back_tcount, 1);

		// intersections with boards
		for (bp = bpos)
			translate([thickness+bp, thickness, 0]) rotate([0, 0, 90])
				teeth(sb_size-thickness, thickness, board_back_tcount, 1);

		// mounting holes
		for (i = [25:20:height])
			translate([i, sb_size*2/3, 0]) circle(d = 5, $fn = 64);
	}
}

module bar() {
	square([height, bar_height]);
}

module overlap() {
	for (i = [0:$children-1]) {
		intersection() {
			union() for (j = [0:$children-1])
				if (i != j) children(j);
			children(i);
		}
	}
}

union() {
	for (bp = bpos)
		translate([0, 0, bp]) linear_extrude(thickness) board();
	for (bp = bpos)
		translate([0, board_depth, bp+thickness+bar_offset])
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

%translate([50, 50, bpos[0]+thickness+0.1]) cylinder(78, r=56/2);
%translate([50, 10, bpos[1]+thickness+0.1]) cube([68, 68, 115]);

*union() {
	for (i = [0:len(bpos)-1])
		translate([0, i*(board_depth+0.001), 0]) board();
	offset1 = len(bpos) * (board_depth+0.001);

	for (i = [0:1])
		translate([0, offset1 + i*(board_depth+0.001), 0]) side();
	offset2 = offset1 + 2 * (board_depth+0.001);

	for (i = [0:1])
		translate([0, offset2 + i*(sb_size+0.001), 0]) sideback();
	offset3 = offset2 + 2 * (sb_size+0.001);

	for (i = [0:len(bpos)-1])
		translate([0, offset3 + i*(bar_height+0.001), 0]) bar();
	offset4 = offset3 + len(bpos) * (bar_height+0.001);
}

