#!/bin/bash

mkdir -pv "$1/cpu"

while true;
	do docker stats --no-stream $1 | tee "$1/cpu/$(gdate +%s%N).txt" &
	sleep 0.3
done;
