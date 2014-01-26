#!/bin/sh

if [ $# -ne 1 ]; then
  echo "Usage: zookeeper-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

#start quorum
mussh -m -u -b -t 6 -H $CONFDIR/zookeepers -c "service zookeeper-server $action"
echo "Done for zookeeper(s) $action."
echo ""
