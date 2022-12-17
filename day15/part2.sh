#!/bin/sh

# awk -F'[ =,:]' '{ print $4, $7, $14, $17 }' |
sed 's/[^0-9-]\+/ /g' |
awk -vROW="${1:-4000000}" '
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

# END { calculate_coverage() }
# END { draw() }

function calculate_coverage() {
	for (y = min_y; y <= max_y; ++y) {
		for (x = min_x; x <= max_x; ++x) {
			for (i = 1; i <= NR; ++i)
			{
				d1 = distance(x,y, sensors_x[i],sensors_y[i])
				d2 = distances[i]
				# printf("sensor at %d/%d has reach %d and distance %d\n", sensors_x[i], sensors_y[i], distances[i], d1)
				# printf("%d - %d = %d\n", d1, d2, d1-d2)
				if (d1<=d2) {
					coverage[at(x,y)] = d1
				}
			}
		}
	}
}

function draw() {
	printf("    ")
	for (x = min_x; x <= max_x; ++x) {
		if (x % 5 == 0) printf("%s", x<0?"-":" ")
		else printf " "
	}
	print ""
	printf("    ")
	for (x = min_x; x <= max_x; ++x) {
		if (x % 5 == 0) printf("%d", int(abs(x)/10))
		else printf " "
	}
	print ""
	printf("    ")
	for (x = min_x; x <= max_x; ++x) {
		if (x % 5 == 0) printf("%d", abs(x)%10)
		else printf " "
	}
	print ""
	for (y = min_y; y <= max_y; ++y) {
		printf("%3d ", y)
		for (x = min_x; x <= max_x; ++x) {
			if (at(x,y) in sensors) printf "S"
			else if (at(x,y) in beacons) printf "B"
			else if (at(x,y) in coverage) printf "#"
			else printf "."
		}
		print ""
	}
}

function find_closest_sensor(x, y) {
	for (i in distances) {
		if (distance(x,y, sensors_x[i],sensors_y[i]) <= distances[i]) {
			return i
		}
	}
	return 0
}

function find_beacon(max) {
	for (y = 0; y < max; ++y) {
		for (x = 0; x < max; ++x) {
			if (!(at(x,y) in beacons) && !(at(x,y) in sensors)) {
			# if (!beacons[at(x,y)] && !sensors[at(x,y)]) {
				sensor_idx = find_closest_sensor(x, y)
				if (!sensor_idx) {
					return x " " y
				} else {
					x = sensors_x[sensor_idx] + distances[sensor_idx] - abs(sensors_y[sensor_idx] - y)
				}
			}
		}

		if (y % 100000 == 0) print "y " y
	}
	return "NOT FOUND"
}

END {
	beacon = find_beacon(ROW)
	print "distress beacon at " beacon

	split(beacon, a)
	print a[1]*4000000 + a[2]
}

'
