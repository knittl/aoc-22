#!/bin/sh

awk '
function abs(x) { return x < 0 ? -x : x; }
function sgn(x) { return (x > 0) - (x < 0); }
function hyp2(a,b) { return a^2 + b^2; }
function move(m) { return m - sgn(m); }
BEGIN {
	HEAD=0
	TAIL=9
	tail[0][0] = 1

	for (k = 0; k <= TAIL; ++k) {
		rope[k]["row"] = 0
		rope[k]["col"] = 0
	}
}
{
	dir=$1
	steps=$2

	for (i = 0; i < steps; ++i) {
		# move head
		switch (dir) {
			case "R": ++rope[HEAD]["col"]; break
			case "L": --rope[HEAD]["col"]; break
			case "U": ++rope[HEAD]["row"]; break
			case "D": --rope[HEAD]["row"]; break
			default: print "error:" dir; break
		}

		# move rope/knots
		for (k = 1; k <= TAIL; ++k) {
			diff_row = rope[k-1]["row"] - rope[k]["row"]
			diff_col = rope[k-1]["col"] - rope[k]["col"]
			rope[k]["row"] += move(diff_row)
			rope[k]["col"] += move(diff_col)
			# diagonal movement (knight)
			if (hyp2(diff_row, diff_col) == 5) {
				if (abs(diff_row) == 1) {
					rope[k]["row"] = rope[k-1]["row"]
				}
				if (abs(diff_col) == 1) {
					rope[k]["col"] = rope[k-1]["col"]
				}
			}

		}

		tail[rope[TAIL]["row"]][rope[TAIL]["col"]] = 1
	}
}
END {
	for (y in tail) for (x in tail[y]) count += tail[y][x]
	print count
}
' input
