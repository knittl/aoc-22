#!/bin/sh

{ printf '[[2]]\n[[6]]\n'; cat; } |
awk '
function comma(s, i) {
	split(s, a, "")
	level = 0
	for (i in a) {
		c = a[i]
		if (c == "[") ++level
		if (c == "]") --level
		if (level == 0 && c == ",") {
			return i
		}
	}
	return i+1
	# return 0
}
function head(s) { return substr(s, 1, comma(s)-1) }
function wrap(s) { return "[" s "]" }
function unwrap(s) { return substr(s, 2, length(s) - 2) }
function islist(s) { return s ~ /^\[/ }
function cmp(a, b) {
	# print "DBG: cmp " a " < " b " ?"
	if (a == b) return 0;

	# if both values are integers
	if ((a b) ~ /^[0-9]+$/) {
		a = +a
		b = +b
		if (a < b) return -1
		if (b < a) return 1
		return 0
	}

	# mixed types: wrap in list
	# if (islist(a) != islist(b)) print "DBG: mixed"
	if (islist(a) && !islist(b)) b = wrap(b)
	if (!islist(a) && islist(b)) a = wrap(a)

	# if both values are lists
	if (islist(a) && islist(b)) {
		# print "DBG: 2 lists"
		a = unwrap(a)
		b = unwrap(b)

		while (a != "" && b != "") {
			a_head = head(a)
			b_head = head(b)
			a = substr(a, length(a_head)+2)
			b = substr(b, length(b_head)+2)

			# print "DBG: a " a_head "::" a
			# print "DBG: b " b_head "::" b

			res = cmp(a_head, b_head)
			if (res != 0) return res
		}
	}


	if (a == "" && b != "") {
		# print "DBG a exhausted"
		return -1;
	}
	if (b == "" && a != "") {
		# print "DBG b exhausted"
		return 1;
	}

	# print "DBG ERROR?"
	# return "ERROR"
	return 0
}

/^$/ { next }
{
	lines[numlines++] = $0
}

END {
# cheap bubble sort
do {
	changed = 0
	for (j = 1; j < numlines; ++j) {
		if (cmp(lines[j-1], lines[j]) > 0) {
			tmp = lines[j-1]
			lines[j-1] = lines[j]
			lines[j] = tmp
			changed = 1
		}
	}
} while (changed == 1)

for (i in lines) print lines[i]
}
' |
	awk '$0 == "[[2]]" || $0 == "[[6]]" { print NR }' |
	awk 'BEGIN{p=1}{p*=$0}END{print p}'
