#!/bin/sh

fold -b1 input | nl | while read -r num char; do
	a=$b
	b=$c
	c=$d
	d=$e
	e=$f
	f=$g
	g=$h
	h=$i
	i=$j
	j=$k
	k=$l
	l=$m
	m=$n
	n=$char

	[ "$a" ] || continue
	[ "$b" ] || continue
	[ "$c" ] || continue
	[ "$d" ] || continue
	[ "$e" ] || continue
	[ "$f" ] || continue
	[ "$g" ] || continue
	[ "$h" ] || continue
	[ "$i" ] || continue
	[ "$j" ] || continue
	[ "$k" ] || continue
	[ "$l" ] || continue
	[ "$m" ] || continue
	[ "$n" ] || continue

	case "$a" in "$b"|"$c"|"$d"|"$e"|"$f"|"$g"|"$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$b" in "$c"|"$d"|"$e"|"$f"|"$g"|"$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$c" in "$d"|"$e"|"$f"|"$g"|"$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$d" in "$e"|"$f"|"$g"|"$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$e" in "$f"|"$g"|"$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$f" in "$g"|"$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$g" in "$h"|"$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$h" in "$i"|"$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$i" in "$j"|"$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$j" in "$k"|"$l"|"$m"|"$n") continue ;; esac
	case "$k" in "$l"|"$m"|"$n") continue ;; esac
	case "$l" in "$m"|"$n") continue ;; esac
	case "$m" in "$n") continue ;; esac

	echo "$num"
	break
done
