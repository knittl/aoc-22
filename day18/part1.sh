#!/bin/sh

awk -F, '
{ cubes[$1][$2][$3] = 1 }

END {
	free_sides = 0
	for (x in cubes) {
		for (y in cubes[x]) {
			for (z in cubes[x][y]) {
				free_sides += 6 - count_connected_sides(x, y, z)
			}
		}
	}

	print free_sides
}

function max(a,b) { return a > b ? a : b }

function count_connected_sides(x, y, z) {
	return left(x,y,z) \
		+ right(x,y,z) \
		+ down(x,y,z) \
		+ up(x,y,z) \
		+ back(x,y,z) \
		+ front(x,y,z)
}

function exists(x,y,z) {
	return x in cubes && y in cubes[x] && z in cubes[x][y] && cubes[x][y][z]
}

function  left(x, y, z) { return exists(x-1,y,z) }
function right(x, y, z) { return exists(x+1,y,z) }

function  down(x, y, z) { return exists(x,y-1,z) }
function    up(x, y, z) { return exists(x,y+1,z) }

function  back(x, y, z) { return exists(x,y,z-1) }
function front(x, y, z) { return exists(x,y,z+1) }



'
