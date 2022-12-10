#!/bin/sh

while read -r op value; do
	case "$op" in
		noop) printf '0\n' ;;
		addx)
			printf '0\n'
			printf '%d\n' "$value"
			;;
	esac
done < input |
	awk 'BEGIN{reg=1}{print NR, reg; reg+=$1}' |
	sed -n "$(seq -s 'p;' 20 40 220)p" |
	awk '{s+=$1*$2}END{print s}'
