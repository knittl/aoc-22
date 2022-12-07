#!/bin/sh

scriptdir="$(realpath "$0")"
scriptdir="${scriptdir%/*}"

root="$(mktemp -d)"

cd "$root"

while read -r first second path; do
	case "$first" in
		'$')
			if [ "$second" = cd ]; then
				if [ "$path" = / ]
				then cd "$root"
				else cd "$path"
				fi
			fi
			;;
		dir) mkdir "$second" ;;
		*) # size
			size="$first"
			path="$second"
			printf '%s\n' "$size" > "$path"
			;;
	esac
done

sum() { "$scriptdir/../sum"; }

find "$root" -type d | while read -r dir; do
	find "$dir" -type f -exec cat {} + | sum
done | awk '{if ($0 < 100000) print}' | sum
