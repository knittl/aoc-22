#!/bin/sh

awk '
$1 == "noop" { print 0 }
$1 == "addx" { print 0; print $2 }
' input |
	awk 'BEGIN{reg=1}{print NR, reg; reg+=$1}' |
	sed -n "$(seq -s 'p;' 20 40 220)p" |
	awk '{s+=$1*$2}END{print s}'
