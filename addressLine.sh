#!/bin/bash

line=$1
type=$2

zip=$(cat address.txt | head -n $line | tail -n 1 | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {print substr($0, RSTART+1, 8)}')
tel=$(cat address.txt | head -n $line | tail -n 1 | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {print substr($0, RSTART - 11, 12)}')
add=$(cat address.txt | head -n $line | tail -n 1 | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {print substr($0, RSTART + 9)}')

#if [ $type == "zip" ]; then
#	cat address.txt | head -n $line | tail -n 1 | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {print substr($0, RSTART+1, 8)}'
#elif [ $type == "tel" ]; then
# 	cat address.txt | head -n $line | tail -n 1 | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {print substr($0, RSTART - 11, 12)}'	
#elif [ $type == "add" ]; then
# 	cat address.txt | head -n $line | tail -n 1 | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {print substr($0, RSTART + 9)}'
#else
#	cat address.txt | head -n $line | tail -n 1
#fi

if [ $type == "zip" ]; then
	echo $zip
else
	echo "$tel, $zip, $add"
fi

