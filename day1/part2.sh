#!/bin/sh
awk '/^$/{print s;s=0}{s+=$0}END{print s}' input |
	sort -nr |
	head -3 |
	awk '{s+=$0}END{print s}'
