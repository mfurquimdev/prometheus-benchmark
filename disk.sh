#!/bin/bash

mkdir -pv "$1/disk"

while true;
	do docker exec $1 du -s | tee "$1/disk/$(gdate +%s%N).txt" &
	sleep 0.3
done;
