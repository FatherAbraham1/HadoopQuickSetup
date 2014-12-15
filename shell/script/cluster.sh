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

echo "manager hadoop on nodes"

for node in $NODES;do
	echo "----$node----"
	ssh $node 'for src in `ls /etc/init.d|grep '$1'`;do service $src '$2'; done'
done
