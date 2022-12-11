#!/bin/sh

echo() { printf '%s\n' "$@"; }
dbg() { echo "$@" >&2; }
product() { awk 'BEGIN{p=1}{p*=$0}END{print p}'; }

mkdir -p monkeys
cd monkeys

while IFS=: read -r key value; do
	key="${key##* }"
	value="${value## }"

	case "$key" in
		[0-9]) monkey="$key" ;;
		items*)
			echo "$value" | sed 's/, /\n/g' > "$monkey.items"
			> "$monkey.items.history"
			;;
		Operation)
			echo "${value#new = }" > "$monkey.op"
			;;
		Test)
			echo "${value#divisible by }" > "$monkey.test"
			;;
		*true|*false)
			echo "${value#throw to monkey }" > "$monkey.test.${key#*If }"
			;;
	esac
done

mod="$(cat *.test | product)"

monkeys="$monkey"

for round in $(seq 10000); do
	for monkey in $(seq 0 "$monkeys"); do
		while read -r item; do
			new="$(sed "s/old/$item/g" "$monkey.op" | bc)"
			new="$((new % mod))"

			if [ "$(echo "$new % $(cat "$monkey".test)" | bc)" -eq 0 ]; then
				dest=true
			else
				dest=false
			fi
			dest="$(cat "$monkey.test.$dest")"

			echo "$new" >> "$dest.items"
		done < "$monkey.items"
		cat "$monkey.items" >> "$monkey.items.history"
		> "$monkey.items"
	done
done

for h in *.items.history; do
	count="$(wc -l < "$h")"
	dbg "Monkey ${h%%.*} inspected items $count times."
	echo "$count"
done | sort -rn | head -2 | product
