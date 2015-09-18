#!/bin/bash

cat address.txt | awk 'match($0,/[0-9]{4}-[0-9]{4}/) {printf("%s\t%s\t%s\n", substr($0, RSTART+1, 8), substr($0, RSTART - 11, 12), substr($0, RSTART + 9))}'



