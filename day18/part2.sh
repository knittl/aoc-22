#!/bin/sh

awk -F, '
BEGIN {
	MAX = 99999
	max_x = max_y = max_z = -MAX
	min_x = min_y = min_z = MAX
}

{
	cubes[key($1,$2,$3)] = 1

	max_x = max(max_x, $1)
	max_y = max(max_y, $2)
	max_z = max(max_z, $3)

	min_x = min(min_x, $1)
	min_y = min(min_y, $2)
	min_z = min(min_z, $3)
}

END {
	free_sides = 0
	for (xyz in cubes) {
		split(xyz, a, "/")
		x = a[1]
		y = a[2]
		z = a[3]

		free_sides += find_outside(x+1,y,z) \
			+ find_outside(x-1,y,z) \
			+ find_outside(x,y+1,z) \
			+ find_outside(x,y-1,z) \
			+ find_outside(x,y,z+1) \
			+ find_outside(x,y,z-1)
	}

	print free_sides
}

function find_outside(x,y,z, visited) {
	if (is_outside(x,y,z)) return 1
	k = key(x,y,z)
	if (exists(k)) return 0
	if (k in visited) return 0
	visited[k] = 1

	return find_outside(x+1,y,z,visited) \
		|| find_outside(x-1,y,z,visited) \
		|| find_outside(x,y+1,z,visited) \
		|| find_outside(x,y-1,z,visited) \
		|| find_outside(x,y,z+1,visited) \
		|| find_outside(x,y,z-1,visited)
}

function key(x,y,z) { return x "/" y "/" z }

function abs(x) { return x < 0 ? -x : x }
function max(a,b) { return a > b ? a : b }
function min(a,b) { return a < b ? a : b }

function is_outside(x,y,z) {
	return x > max_x || x < min_x || y > max_y || y < min_y || z > max_z || z < min_z
}

function in_cubes(xyz) { return xyz in cubes }
function exists(xyz) { return in_cubes(xyz) && cubes[xyz] }
'
