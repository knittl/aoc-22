#!/bin/sh

# awk '{print substr($0,1,length/2); print substr($0,length/2+1)}' input

while read -r line; do
	printf '%s' "$line" | fold -b1 | sort -u | tr -d '\n'
	printf '\n'
done < input |
paste -sd'--\n' |
while read -r line; do
	printf '%s' "$line" | tr '-' '\n' | fold -b1 | sort | uniq -c | sort -nr | head -1 | rev | cut -c1
done | while read -r c; do
	ord="$(case "$c" in
		([A-Z]) printf '%d' "'$c" ;;
		([a-z]) printf '%d' "'$c" ;;
	esac)"
	case "$c" in
		[A-Z]) printf '%d\n' "$((ord-38))" ;;
		[a-z]) printf '%d\n' "$((ord-96))" ;;
	esac
done | ../sum
