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

total=70000000
required=30000000
current="$(find "$root" -type f -exec cat {} + | sum)"
left="$((total-current))"
missing="$((required-left))"

find "$root" -type d | while read -r dir; do
	find "$dir" -type f -exec cat {} + | sum
done |
	awk -v missing="$missing" '{if ($0 >= missing) print}' |
	sort -n |
	head -1
