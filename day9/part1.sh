#!/bin/sh

awk '
function abs(x) { return x < 0 ? -x : x; }
BEGIN {
	tail[0][0] = 1
	tail_row = tail_col = 0
}
{
	dir=$1
	steps=$2

	for (i = 0; i < steps; ++i) {
		prev_head_row = head_row
		prev_head_col = head_col

		# move head
		switch (dir) {
			case "R": ++head_col; break
			case "L": --head_col; break
			case "U": ++head_row; break
			case "D": --head_row; break
			default: print "error:" dir; break
		}

		# move tail
		diff_row = head_row - tail_row
		diff_col = head_col - tail_col
		if (abs(diff_row) > 1 || abs(diff_col) > 1) {
			tail_row = prev_head_row
			tail_col = prev_head_col
		}

		tail[tail_row][tail_col] = 1
	}
}
END {
	for (y in tail) for (x in tail[y]) count += tail[y][x]
	print count
}
' input
