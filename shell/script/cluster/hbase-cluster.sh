#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hbase-cluster.sh start|stop|restart|status"
  exit 1
fi

CONFDIR=/etc/edh/conf

action=$1

if [ -s $CONFDIR/hbase_masters ] ;then
	pssh -P -i -h $CONFDIR/hbase_masters "service hbase-master $action"
	echo "Done for HBase Master(s) $action."
	echo ""
fi

if [ -s $CONFDIR/hbase_regionservers ] ;then
	pssh -P -i -h $CONFDIR/hbase_regionservers "service hbase-regionserver $action"
	echo "Done for HBase RegionServer(s) $action."
	echo ""
fi

if [ -s $CONFDIR/hbase_thrifts ] ;then
	pssh -P -i -h $CONFDIR/hbase_thrifts "service hbase-thrift $action"
	echo "Done for HBase thrift server(s) $action."
	echo ""
fi
