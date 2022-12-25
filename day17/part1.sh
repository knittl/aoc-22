#!/bin/sh

awk '
BEGIN {
	ROCKS = 2022
	EMPTY = "       "
	ROCK_DIST = 3

	rocks["minus"][0] = "####"

	rocks["plus"][0] = " # "
	rocks["plus"][1] = "###"
	rocks["plus"][2] = " # "

	rocks["ell"][0] = "###"
	rocks["ell"][1] = "  #"
	rocks["ell"][2] = "  #"

	rocks["bar"][0] = "#"
	rocks["bar"][1] = "#"
	rocks["bar"][2] = "#"
	rocks["bar"][3] = "#"

	rocks["block"][0] = "##"
	rocks["block"][1] = "##"

	rocks_sequence[0] = "minus"
	rocks_sequence[1] = "plus"
	rocks_sequence[2] = "ell"
	rocks_sequence[3] = "bar"
	rocks_sequence[4] = "block"
}

END {
	chars($0, jet)
	rock_top = 0

	move = 0
	for (i = 0; i < ROCKS; ++i) {
		selected_rock = rocks_sequence[i%count(rocks)]
		rock_height = count(rocks[selected_rock])

		rock_y = rock_top + ROCK_DIST
		rock_x = 2

		# make space in chamber
		while (count(chamber) < rock_y + rock_height) append(EMPTY)

		print "Dropping rock #" i " at " rock_x "/" rock_y
		print_rock(rocks[selected_rock])

		# fall
		fall = 1
		do {
			# push sideways
			current_jet = jet[(move % count(jet))+1]
			direction = current_jet == ">" ? 1 : -1
			shift = try_shift(rocks[selected_rock], rock_x, rock_y, direction)
			rock_x += shift

			# fall down
			fall = try_fall(rocks[selected_rock], rock_x, rock_y)
			rock_y -= fall

			print "#" move " " current_jet " " rock_x "/" rock_y

			++move
		} while(fall)

		place_rock(rocks[selected_rock], rock_x, rock_y)
		rock_top = max(rock_top, rock_y + rock_height)

		# print_chamber()
	}

	print "Tower height " rock_top
}

function place_rock(rock, rock_x, rock_y,   y, x, rock_height) {
	rock_height = count(rock)
	for (y = 0; y < rock_height; ++y) {
		chars(rock[y], src)
		chars(chamber[rock_y+y], dst)
		for (x in src) if (src[x] != " ") dst[x+rock_x] = src[x]
		chamber[rock_y+y] = join(dst)
	}
}

function try_shift(rock, rock_x, rock_y,   offset, rock_height, x, y, src, dst) {
	if (rock_x + offset < 0) return 0
	rock_height = count(rock)
	for (y = 0; y < rock_height; ++y) {
		chars(rock[y], src)
		chars(chamber[rock_y+y], dst)
		for (x in src) {
			if (src[x] != " ") if (dst[x+rock_x+offset] != " ") return 0
		}
	}
	return offset
}

function try_fall(rock, rock_x, rock_y,   rock_height, x, y, src, dst) {
	if (rock_y <= 0) return 0
	rock_height = count(rock)
	for (y = 0; y < rock_height; ++y) {
		chars(rock[y], src)
		chars(chamber[rock_y+y-1], dst)
		for (x in src) {
			if (src[x] != " ") if (dst[x+rock_x] != " ") return 0
		}
	}
	return 1
}

function chars(s, array) { split(s, array, "") }

function join(a,   joined, i) {
	joined = ""
	for (i in a) joined = joined "" a[i]
	return joined
}

function append(line) { chamber[count(chamber)] = line }

function count(a,   i, cnt) {
	cnt = 0
	for (i in a) ++cnt
	return cnt
}

function print_rock(rock,   i) {
	for (i = count(rock)-1; i >= 0; --i) print rock[i]
}

function print_chamber(limit,   i, height) {
	height = count(chamber)
	if (limit) limit = max(0, height-limit)
	for(i=height-1; i>=limit; --i) {
		printf("%5s ", i)
		print_line(chamber[i])
	}
	print "      +-------+"
	print "       0123456 "
	print ""
}

function print_line(line) { printf("|%-7s|\n", line) }

function max(a,b) { return a > b ? a : b }
'
