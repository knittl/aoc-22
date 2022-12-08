#!/bin/sh
alias grep='grep --color'
# assumption: map is square

file=input
size="$(wc -l < "$file")"

distance() { grep -oE "^[^$tree-9]*([$tree-9]|$)"; }
chars() { tr -d '\n' | wc -c; }

score() {
	tree="$1"
	trees="$2"
	pos="$3"
	if [ "$pos" -eq 1 ]; then
		printf '0\n'
		return
	fi
	printf '%s\n' "$trees" | cut "-c1-$((pos-1))" | rev | distance | chars
	printf '%s\n' "$trees" | cut "-c$((pos+1))-" | distance | chars
}

for i in $(seq "$size"); do
	line="$(sed -n "${i}p" "$file")"
	for j in $(seq "$size"); do
		col="$(cut "-c$j" "$file" | paste -sd'\0')"
		tree="$(printf '%s\n' "$line" | cut "-c$j")"

		{
			score "$tree" "$line" "$j"
			score "$tree" "$col" "$i"
		} | awk 'BEGIN{p=1}{p*=$0}END{print p}'
	done
done | sort -nr | head -1
