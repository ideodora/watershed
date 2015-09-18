SCRIPT=$(readlink $0)
echo $SCRIPT

DIR=$(dirname ${SCRIPT})
#DIR=$(cd -P $(readlink $0) && pwd -P)

echo $DIR

