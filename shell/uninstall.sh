#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

if [ $# == 0 ]; then
  echo "USAGE:
  ./uninstall.sh ALL|all
  ./uninstall.sh node1 node2 node3 ...
  "; exit 1;
fi

function continue_ask {
	continue_flag="undef"
	while [ "$continue_flag" != "yes" -a "$continue_flag" != "no" ]
	do
		echo -n "[INFO]:Type yes to continue or no to exit uninstallation...[yes|no]: "
		read continue_flag
		if [ "$continue_flag" == "no" ]; then
		  	return 1
		fi
	done
	return 0
}

sh $PROGDIR/bin/remove_node.sh

NODES_FILE=$PROGDIR/conf/nodes
if [ "$1" == "ALL" ] || [ "$1" == "all" ]; then
	continue_ask
	if [ -f $NODES_FILE ]; then
		pssh -i -h $NODES_FILE  "`cat remove_node.sh` "
	else
		echo "[ERROR]: Can not found role configuration file $NODES_FILE"
		exit 1
	fi
else
	NODES=$*
	continue_ask

	pssh -P -i -H $NODES "`cat remove_node.sh`"
fi
