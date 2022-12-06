#!/bin/sh

fold -b1 input | nl | while read -r num char; do
	a=$b
	b=$c
	c=$d
	d=$char

	[ "$a" ] || continue
	[ "$b" ] || continue
	[ "$c" ] || continue

	case "$a" in "$b"|"$c"|"$d") continue ;; esac
	case "$b" in "$c"|"$d") continue ;; esac
	case "$c" in "$d") continue ;; esac

	echo "$num"
	break
done
