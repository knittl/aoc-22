#!/bin/sh

# awk -F'[ =,:]' '{ print $4, $7, $14, $17 }' |
sed 's/[^0-9-]\+/ /g' |
awk -vROW="$1" '
BEGIN {
	MAX = 99999999
	max_x = -MAX
	max_y = -MAX
	min_x = MAX
	min_y = MAX
}

function max(a,b) { return a < b ? b : a }
function min(a,b) { return a < b ? a : b }
function abs(x) { return x < 0 ? -x : x }

function at(x,y) { return (y-min_y)*(max_x-min_x+1) + (x-min_x) }

function distance(x1,y1, x2,y2) { return abs(x1-x2) + abs(y1-y2) }

{
	lines[NR] = $0
	sensors_x[NR] = $1
	sensors_y[NR] = $2
	dist = distance($1,$2, $3,$4)
	distances[NR] = dist

	min_x = min(min_x, min($1-dist, $3))
	max_x = max(max_x, max($1+dist, $3))

	min_y = min(min_y, min($2-dist, $4))
	max_y = max(max_y, max($2+dist, $4))
}

END {
	print "min: " min_x "/" min_y
	print "max: " max_x "/" max_y
	print "x: " min_x " - " max_x
	print "y: " min_y " - " max_y
}

END {
	for (line in lines) {
		split(lines[line], a)
		sensors[at(a[1],a[2])] = "S"
		beacons[at(a[3],a[4])] = "B"
	}
}

# END {
# 	for (y = min_y; y <= max_y; ++y) {
# 		for (x = min_x; x <= max_x; ++x) {
# 			for (i = 0; i <= NR; ++i)
# 			{
# 				d1 = distance(x,y, sensors_x[i],sensors_y[i])
# 				d2 = distances[i]
# 				# printf("sensor at %d/%d has reach %d and distance %d\n", sensors_x[i], sensors_y[i], distances[i], d1)
# 				# printf("%d - %d = %d\n", d1, d2, d1-d2)
# 				if (d1<=d2) {
# 					coverage[at(x,y)] = d1
# 				}
# 			}
# 		}
# 	}
# }

# END { draw() }

function draw() {
	printf("    ")
	for (x = min_x; x <= max_x; ++x) {
		if (x % 5 == 0) printf("%d", int(x/10))
		else printf " "
	}
	print ""
	printf("    ")
	for (x = min_x; x <= max_x; ++x) {
		if (x % 5 == 0) printf("%d", x%10)
		else printf " "
	}
	print ""
	for (y = min_y; y <= max_y; ++y) {
		printf("%3d ", y)
		for (x = min_x; x <= max_x; ++x) {
			if (sensors[at(x,y)]) printf "S"
			else if (beacons[at(x,y)]) printf "B"
			else if (coverage[at(x,y)]) printf "#"
			else printf "."
		}
		print ""
	}

}

function has_coverage(x, y) {
	for (i in distances) {
		if (distance(x,y, sensors_x[i],sensors_y[i]) <= distances[i]) {
			return 1
		}
	}
	return 0
}

END {
	y = ROW
	for (x = min_x; x < max_x; ++x) {
		# if (!(at(x,y) in beacons) && !(at(x,y) in sensors)) {
		if (!beacons[at(x,y)] && !sensors[at(x,y)]) {
			if (has_coverage(x, y)) {
				++covered_cells
			}
		}
	}

	print covered_cells
}

'
