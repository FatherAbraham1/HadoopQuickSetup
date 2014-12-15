#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"


NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode
NODES_FILE=$PROGDIR/../conf/nodes

if [ ! -f $NODES_FILE ]; then
    echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

NODES=`cat $NODES_FILE`

echo "run commands on nodes"

for node in $NODES;do
	echo "----$node----"
	ssh root@$node $1
done
