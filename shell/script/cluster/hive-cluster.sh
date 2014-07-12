#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hive-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

pssh -P -i -h $CONFDIR/manager "service hive-metastore $action"
echo "Done for Hive MetaStore $action."
echo ""

#if [ -s $CONFDIR/hive_servers ] ;then
#	mussh -m -u -b -t 6 -H $CONFDIR/hive_servers -c "service hive-server $action"
#	echo "Done for Hive server(s) $action."
#	echo ""
#fi

if [ -s $CONFDIR/hive_server2s ] ;then
	pssh -P -i -h $CONFDIR/hive_server2s "service hive-server2 $action"
	echo "Done for Hive server2(s) $action."
	echo ""
fi

