#!/bin/sh

if [ $# == 0 ]; then
  echo "USAGE: 
  ./uninstall.sh ALL|all
  ./uninstall.sh node1 node2 node3 ... 
  "; exit 1; 
fi

NODES_FILE="/etc/edh/nodes.csv"
if [ "$1" == "ALL" ] || [ "$1" == "all" ]; then
	if [ -f $NODES_FILE ]; then
		NODES_LIST=`cat $NODES_FILE`
	else
		echo "ERROR: Can not found role configuration file $NODES_FILE"
		exit 1
	fi
else
	NODES_LIST=$*
fi

for node in $NODES_LIST ;do
        ssh root@$node  "`cat script/clear_node.sh`"
done

