#!/bin/sh

while read -r line; do
	len="$((${#line}/2))"
	{
		printf '%s' "$line" | head "-c$len" | fold -b1 | sort -u
		printf '%s' "$line" | tail "-c$len" | fold -b1 | sort -u
	} | sort | uniq -d
done < input | while read -r c; do
	ord="$(case "$c" in
		([A-Z]) printf '%d' "'$c" ;;
		([a-z]) printf '%d' "'$c" ;;
	esac)"
	case "$c" in
		[A-Z]) printf '%d\n' "$((ord-38))" ;;
		[a-z]) printf '%d\n' "$((ord-96))" ;;
	esac
done | ../sum
