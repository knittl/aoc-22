#!/bin/sh

# assumption: map is square

file=input
size="$(wc -l < "$file")"

visible() {
	tree="$1"
	trees="$2"
	pos="$3"
	[ "$pos" -eq 1 ] ||
		printf '%s\n' "$trees" | cut "-c1-$((pos-1))" | grep -vq "[$tree-9]" ||
		printf '%s\n' "$trees" | cut "-c$((pos+1))-" | grep -vq "[$tree-9]"
}

for i in $(seq "$size"); do
	line="$(sed -n "${i}p" "$file")"
	for j in $(seq "$size"); do
		col="$(cut "-c$j" "$file" | paste -sd'\0')"
		tree="$(printf '%s\n' "$line" | cut "-c$j")"

		visible "$tree" "$line" "$j" ||
			visible "$tree" "$col" "$i" &&
			echo "$tree visible at ${i}x${j}"
	done
done | wc -l
