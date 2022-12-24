#!/bin/sh

sed -E 's/(^V)?[^A-Z0-9]+/ /g' |
sort |
awk '
BEGIN {
	TIME = 26
	START = "AA"
	TIME_TO_OPEN = 1
	TIME_TO_MOVE = 1
}

{
	lines[NR] = $0
	valve = $1
	valves[valve] = 1
	closed[valve] = 1
	rates[valve] = $2
	print

	$1 = $2 = ""
	split($0, a)

	for (i in a) neighbors[valve][a[i]] = 1
}

END { MAX_DIST = NR + 1 }

END {
	calc_distances()
	draw_distance_matrix()

	# reduce/compact rates array
	for (v in rates) {
		if (v != START && rates[v] == 0) {
			rates_to_delete[v] = 1
			delete rates[v]
		}
	}

	# reduce/compact distance matrix
	for (src in valves) {
		for (dst in valves) {
			if (dst in rates_to_delete) {
				delete distances[src][dst]
			}
		}
	}

	draw_distance_matrix()

	current_best = 0

	clone(rates, pool)
	printf("Pool: ")
	pprint(pool)

	print "starting best " current_best

	clear(best_vector)
	clear(vector)
	pick(vector, pool, START)
	find(vector, pool)

	print "===="
	printf("configuration: ")
	pprint(best_vector)
	print "counter: " counter
	print "time: " time_required(best_vector)
	print "flow: " total_flow(best_vector)

	flow1 = total_flow(best_vector)

	clone(rates, remaining_pool)

	time = 0
	len = count(best_vector) - 1
	for (i=0; i < len; ++i) {
		src = best_vector[i]
		dst = best_vector[i+1]
		time += distances[src][dst] + TIME_TO_OPEN
		if (time > TIME) break
		delete remaining_pool[src]
		delete remaining_pool[dst]
	}

	print "Remaining pool:"
	pprint(remaining_pool)

	current_best = 0
	clear(best_vector)
	clear(vector)
	pick(vector, remaining_pool, START)
	find(vector, remaining_pool)

	print "===="
	printf("configuration: ")
	pprint(best_vector)
	print "counter: " counter
	print "time: " time_required(best_vector)
	print "flow: " total_flow(best_vector)

	print "========"
	print total_flow(best_vector) + flow1
}

function find(vector, pool,  candidate, new_pool) {
	++counter
	if (count(pool) <= 0) {
		vector_flow = total_flow(vector)
		printf("terminate %4s [%2s] ", vector_flow, time_required(vector))
		pprint(vector)

		if (vector_flow > current_best) {
			current_best = vector_flow
			clone(vector, best_vector)
		}
		return
	}

	for (p in pool) {
		clone(vector, candidate)
		clone(pool, new_pool)

		pick(candidate, new_pool, p)
		candidate_time = time_required(candidate)

		e = total_flow(candidate) + estimate(new_pool, TIME-candidate_time)
		if (e <= current_best) {
			continue
		}

		find(candidate, new_pool)
	}
}

function pick(vector, pool, valve) {
	vector[count(vector)] = valve
	delete pool[valve]
}

function estimate(a, time_left,  v, total) {
	total = 0
	for (v in a) total += rates[v]
	time_left = time_left < 0 ? 0 : time_left
	return total*time_left
}

function find_index(a, v, idx) {
	for (idx in a) if (a[idx] == v) return idx;
	return ""
}

function pprint(a, x) {
	for (x in a) printf x"="a[x] " "
	# for (x in a) printf a[x] " "
	print ""
}

function swap(a, i, j, tmp) {
	tmp = a[i]
	a[i] = a[j]
	a[j] = tmp
}

function time_required(config, i, len, time) {
	time = 0
	len = count(config) - 1
	for (i=0; i < len; ++i) {
		src = config[i]
		dst = config[i+1]
		time += distances[src][dst] + TIME_TO_OPEN
	}
	return time + TIME_TO_OPEN
}

function total_flow(config, i, time, len, total) {
	time = 0;
	len = count(config) - 1
	total = 0
	for (i=0; i < len; ++i) {
		src = config[i]
		dst = config[i+1]

		time += distances[src][dst] + TIME_TO_OPEN

		if (time > TIME) break

		total += (TIME - time) * rates[dst]
	}

	return total
}

function clear(a) { split("", a) }
function copy(src, dst) { for (e in src) dst[e] = src[e] }
function clone(src, dst) { clear(dst); copy(src, dst); }
function count(a, cnt, e) { cnt = 0; for (e in a) ++cnt; return cnt }

function calc_distances() {
	for (src in valves) for (dst in valves) distances[src][dst] = MAX_DIST

	for (src in valves) {
		for (dst in valves) unvisited[dst] = 1
		distances[src][src] = 0 # zero distance to node itself
		for (dst in valves) {
			while (dst in unvisited) {
				current = find_nearest_unvisited_valve(unvisited, distances[src])
				update_neighbor_distances(current)
				delete unvisited[current]
			}
		}
	}
}

function update_neighbor_distances(current) {
	for (neighbor in neighbors[current]) {
		if (neighbor in unvisited) {
			new_dist = distances[src][current] + 1
			distances[src][neighbor] = min(distances[src][neighbor], new_dist)
		}
	}
}

function draw_distance_matrix() {
	split("", seen)
	FMT = "%3s"
	printf(FMT, "")
	for (dst in rates) {
		printf(FMT, dst)
	}
	print ""
	for (src in rates) {
		printf(FMT, src)
		for (dst in rates) {
			if (dst in seen) printf(FMT, "")
			else printf(FMT, distances[src][dst])
		}
		seen[src] = 1
		print ""
	}
}

function find_nearest_unvisited_valve(unvisited, distance, min_dist, valve) {
	min_dist = MAX_DIST
	valve = 0
	for (v in unvisited) {
		if (distance[v] < min_dist) {
			valve = v
			min_dist = distance[v]
		}
	}
	return valve
}

function min(a,b) { return a < b ? a : b }
'
