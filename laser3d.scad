// Generic functions used for designing 3D objects built from laser cut
// parts.


// =================== Functions =================

// OpenSCAD as a functional programming language is a bit broken.
// :-(

// Returns a slice of a vector.
// vec   is the vector to slice.
// start is the index of the first element that is contained in the
//       slice.
// end   is the index of the first element that is no longer contained
//       in the slice.
function slice(vec, start, end) =
	start == end ? [] :
		[for (i = [start : end-1]) vec[i]];

// Sum of all elements of a vector
function sum(vec) =
	len(vec) == 0 ?      0 : (
	len(vec) == 1 ? vec[0] : (
		sum(slice(vec, 0,                 floor(len(vec)/2))) +
		sum(slice(vec, floor(len(vec)/2), len(vec)))));




// =================== 2D ========================

// Generic teeth calculation module
// Do not use directly! Use teethA and teethB instead!
module teeth(length, depth, count, start = 0) {
	if (!($play > 0))
		echo("<b>$play needs to be positive!</b>");

	size = length / count;
	for (i = [start:2:count])
		translate([i*size-$play, -$play, 0])
			square([size+$play*2, depth+$play*2]);
}

// Teeth
// Teeth will fit if length and count were the same for both parts
// that should fit together. Use teethA on one part and teethB on the
// other.
module teethA(length, depth, count) {teeth(length, depth, count, 0);}
module teethB(length, depth, count) {teeth(length, depth, count, 1);}



// =================== 3D ========================

// This is a drop-in replacement for OpenSCADs union().
// This will not calculate the union of the children, but the overlap.
// This will enable you to find errors in the design of your parts.
// If the result is not empty, you will not be able to assemble the
// parts later on.
module overlap() {
	for (i = [0:$children-1]) {
		intersection() {
			union() for (j = [0:$children-1])
				if (i != j) children(j);
			children(i);
		}
	}
}

