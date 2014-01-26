#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hbase-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

if [ -s $CONFDIR/hbase_masters ] ;then
	mussh -m -u -b -t 6 -H $CONFDIR/hbase_masters -c "service hbase-master $action"
	echo "Done for HBase Master(s) $action."
	echo ""
fi

if [ -s $CONFDIR/hbase_regionservers ] ;then
	mussh -m -u -b -t 6 -H $CONFDIR/hbase_regionservers -c "service hbase-regionserver $action"
	echo "Done for HBase RegionServer(s) $action."
	echo ""
fi

if [ -s $CONFDIR/hbase_thrifts ] ;then
	mussh -m -u -b -t 6 -H $CONFDIR/hbase_thrifts -c "service hbase-thrift $action"
	echo "Done for HBase thrift server(s) $action."
	echo ""
fi
