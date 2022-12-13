#!/bin/sh

awk '
BEGIN {
	MAX=999
	for(n=0;n<128;n++) _ord[sprintf("%c",n)]=n
}

{
	split($0, line, "")
	for (col in line) {
		cell = line[col]
		map[NR][col] = cell
		height[NR][col] = ord(cell) - ord("a")
		steps[NR][col] = MAX
		coords[NR][col] = NR "x" col
		if (cell == "E") {
			end_y = pos_y = NR
			end_x = pos_x = col
			steps[NR][col] = 0
			height[NR][col] = ord("z") - ord("a")
		} else if (cell == "S") {
			height[NR][col] = ord("a") - ord("a")
			start_x = col
			start_y = NR
		}
	}
	cols=length($0)
	rows=NR
}

END {
	print "Start " key(start_x, start_y)
	print "End " key(end_x, end_y)
	edges[key(end_x, end_y)] = 1

	for (i = 0; i < MAX; ++i) {
		for (edge in edges) {
			split(edge, e, "x")
			x = e[1]
			y = e[2]

			if (x <= 1 || x >= cols-1) continue;
			if (y <= 1 || y >= rows-1) continue;

			current_height = here(height, x, y)
			new_steps = here(steps, x, y) + 1

			if (current_height - left(height, x, y) <= 1) {
				current_steps = left(steps, x, y)
				if (new_steps < current_steps) {
					steps[y][x-1] = new_steps
					edges[key(x-1,y)] = 1
				}
			}
			if (current_height - right(height, x, y) <= 1) {
				current_steps = right(steps, x, y)
				if (new_steps < current_steps) {
					steps[y][x+1] = new_steps
					edges[key(x+1,y)] = 1
				}
			}
			if (current_height - up(height, x, y) <= 1) {
				current_steps = up(steps, x, y)
				if (new_steps < current_steps) {
					steps[y-1][x] = new_steps
					edges[key(x,y-1)] = 1
				}
			}
			if (current_height - down(height, x, y) <= 1) {
				current_steps = down(steps, x, y)
				if (new_steps < current_steps) {
					steps[y+1][x] = new_steps
					edges[key(x,y+1)] = 1
				}
			}

			delete edges[edge]
		}
	}

	best_starting_steps = MAX
	for (row in map) {
		for (col in map[row]) {
			c = map[row][col]
			if (c ~ /[Sa]/) {
				if (steps[row][col] < best_starting_steps) {
					best_starting_steps = steps[row][col]
				}
			}
		}
	}

	print cols "x" rows
	# pprint(steps, " ")
	# pprint(map)
	print best_starting_steps

}

function here(matrix, x, y) { return matrix[y][x] }
function left(matrix, x, y) { return matrix[y][x-1] }
function right(matrix, x, y) { return matrix[y][x+1] }
function up(matrix, x, y) { return matrix[y-1][x] }
function down(matrix, x, y) { return matrix[y+1][x] }

function pprint(matrix, sep) {
	for (row in matrix) {
		for (col in matrix[row]) {
			v = matrix[row][col]
			printf "%s%s", (v==MAX?".":v), sep
		}
		print ""
	}
}

function key(x,y) { return x "x" y }
function ord(c) { return _ord[c] }
'
