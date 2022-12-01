#!/bin/sh
awk '/^$/{print s;s=0}{s+=$0}END{print s}' input | sort -nr | head -1
