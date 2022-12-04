#!/bin/sh

between() {
	[ "$1" -ge "$2" ] && [ "$1" -le "$3" ]
}

while IFS=-, read -r a b c d; do
	if between "$a" "$c" "$d" || between "$b" "$c" "$d" \
		|| between "$c" "$a" "$b" || between "$d" "$a" "$b"; then
		echo 1
	fi
done < input | wc -l
