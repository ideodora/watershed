#!/bin/bash
SCRIPT=$(readlink $0)
DIR=$(dirname ${SCRIPT})
cd $DIR

PROGNAME=$(basename $0)
VERSION="1.0"

#
# usage
#
usage() {
	echo "Usage:"
	echo "	$PROGNAME [OPTIONS] LineNumber"
	echo
	echo "	This script is ~."
	echo
	echo "Options:"
	echo "	-h"
	echo "	-v"
	echo "	-a"
	echo "	-t"
	echo "	-z"
	echo
	exit 1
}



lineCount=$(cat address.txt | grep -c "")

#
# getopts
#
while getopts :hvazt OPT; do
  case $OPT in
		h) usage;;
		v) echo $VERSION
			exit
			;;
    z) ENABLE_z="t";;
    a) ENABLE_a="t";;
    t) ENABLE_t="t";;
    *) echo "Unexpected Option.";;
  esac
done

shift `expr ${OPTIND} - 1`

#
# check
#
if [ "${ENABLE_a}${ENABLE_z}${ENABLE_t}" = "" ] || [  "${ENABLE_a}${ENABLE_z}${ENABLE_t}" = "ttt" ]; then
	ENABLE_all="t"
else
	ENABLE_all="f"
fi


#
# exec
#
if [ "${ENABLE_all}" = "t" ]; then
 	if [ -z $1 ]; then
		./addressLine2.sh | awk 'BEGIN{OFS=", "} {print $1,$2,$3}'
	elif [ $1 -le $lineCount ]; then
		./addressLine2.sh | awk 'BEGIN{OFS=", "} NR=='"$1"' {print $1,$2,$3}'
	fi
else
	if [ "${ENABLE_z}" = "t" ]; then
		format=",\$1"
	fi
	if [ "${ENABLE_t}" = "t" ]; then
		format="${format},\$2"
	fi
	if [ "${ENABLE_a}" = "t" ]; then
		format="${format},\$3"
	fi

	format2=$(echo $format | awk '{print substr($0,2)}')
 	if [ -z $1 ]; then
		./addressLine2.sh | awk 'BEGIN{OFS=", "} {print '"${format2}"'}'
	elif [ $1 -le $lineCount ]; then
		./addressLine2.sh | awk 'BEGIN{OFS=", "} NR=='"$1"' {print '"${format2}"'}'
	fi
fi

