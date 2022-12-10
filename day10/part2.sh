#!/bin/sh

awk '
$1 == "noop" { print 0 }
$1 == "addx" { print 0; print $2 }
' input |
	awk 'BEGIN{reg=1}{print NR, reg; reg+=$1}' |
	awk '
	function abs(x) { return x < 0 ? -x : x; }
	{ printf "%s", (abs(($1-1)%40 - $2) <= 1) }
	' |
	tr 01 '.#' |
	fold -b40
