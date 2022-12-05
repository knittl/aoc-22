#!/bin/sh

last() { last_n 1; }
last_n() { grep -o '.\{'"$1"'\}$'; }
stacks() { printf '%s\n' "$stacks"; }
collapse() { paste -sd'\0'; }

stacks=$(sed '/^$/Q' input | tac)

stacks=$(
for stack in $(seq 2 4 34); do
	stacks | cut "-c$stack" | collapse | sed 's/ *$//'
done
)

sed '0,/^$/d' input | {
	while read -r move amount from from to to; do
		crates=$(stacks | sed -n "${from}p" | last_n "$amount")
		stacks=$(stacks | sed "${from}s/\(.*\).\{${amount}\}\$/\1/;${to}s/$/${crates}/")
	done

	stacks | last | collapse
}
