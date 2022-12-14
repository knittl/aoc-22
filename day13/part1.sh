#!/bin/sh

paste -sd ' \0\n' |

awk '
function comma(s) {
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

cmp($1, $2) == -1 { print NR }

{
	# print $1 " < " $2
	# print NR, cmp($1, $2)
}
' |
../sum
