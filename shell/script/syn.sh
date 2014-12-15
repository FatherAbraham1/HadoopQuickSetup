#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NODES_FILE=$PROGDIR/../conf/nodes

if [ ! -f $NODES_FILE ]; then
    echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

NODES=`cat $NODES_FILE`

echo "scp file to nodes"

for node in $NODES;do
	echo "----$node----"
	scp -rp $1 root@$node:$2
done
