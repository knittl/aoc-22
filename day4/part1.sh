#!/bin/sh

while IFS=-, read -r a b c d; do
	if [ "$a" -le "$c" ] && [ "$b" -ge "$d" ]; then
		echo 1
	elif [ "$c" -le "$a" ] && [ "$d" -ge "$b" ]; then
		echo 1
	fi
done < input | wc -l
