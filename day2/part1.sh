#!/bin/sh

tr 'ABCXYZ' 'RPSRPS' | while read -r opp my; do
	case "$my" in
		R) points=1 ;;
		P) points=2 ;;
		S) points=3 ;;
	esac

	case "$opp$my" in
		RR|PP|SS) points="$((points+3))" ;;
		SR|RP|PS) points="$((points+6))" ;;
	esac

	printf '%s\n' "$points"
done | awk '{s+=$0}END{print s}'
