#!/bin/sh

awk '
BEGIN {
	MAX = 99999
	max_x = 0
	max_y = 0
	min_x = MAX
	min_y = MAX
	source = at(500, 0)
	cave[source] = "+"
}

function max(a,b) { return a < b ? b : a }
function min(a,b) { return a < b ? a : b }

function at(x,y) { return y*max_x + x }

function down(idx) { return idx + max_x }
function left(idx) { return idx + max_x - 1 }
function right(idx) { return idx + max_x + 1 }

{
	lines[NR] = $0
	split($0, coords, " -> ")
	for (i in coords) {
		split(coords[i], xy, ",")
		max_x = max(max_x, xy[1])
		max_y = max(max_y, xy[2])
		min_x = min(min_x, xy[1])
	}

	bottom = max_y
}

END {
	for (line in lines) {
		line = lines[line]
		split(line, coords, " -> ")

		prev_coords = ""
		for (i in coords) {
			split(coords[i], xy, ",")
			if (prev_coords != "") {
				split(prev_coords, prev_xy, ",")
				x = xy[1]
				y = xy[2]
				if (x == prev_xy[1]) {
					# vertical
					for (y = min(prev_xy[2], xy[2]); y <= max(prev_xy[2], xy[2]); ++y) {
						cave[at(x, y)] = "#"
					}
				} else {
					# horizontal
					for (x = min(prev_xy[1], xy[1]); x <= max(prev_xy[1], xy[1]); ++x) {
						cave[at(x, y)] = "#"
					}
				}
			}
			prev_coords = coords[i]
		}
	}
}

function free(idx) { return cave[idx] == "" }
function drop(source, resting) {
	prev = source
	sand = down(source)
	do {
		if (free(down(sand))) sand = down(sand)
		else if (free(left(sand))) sand = left(sand)
		else if (free(right(sand))) sand = right(sand)
		if (sand == prev) resting = 1
		if (sand / max_x > max_y) return 0
		prev = sand
	} while(!resting)
	return 1
}

END {
	while (drop(source)) {
		cave[sand] = "o"
		sands++
	}
}

END { draw(cave) }
END { print sands }

function draw(cave) {
	for (y = 0; y <= bottom; ++y) {
		for (x = min_x; x <= max_x; ++x) {
			c = cave[at(x,y)]
			printf("%s", c==""?" ":c)
		}
		print ""
	}
}
'
