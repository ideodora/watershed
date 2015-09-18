#!/bin/bash

while getopts "zat" OPTION
do
	case $OPTION in
		z) echo "z!";;
		a) echo "a!";;
		t) echo "t!";;
		*) echo "Unexpected Option.";;
	esac
done

