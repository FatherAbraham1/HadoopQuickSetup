#!/bin/sh
#usage: zookeeper-service zookeeper [start|stop|restart|status]
service=$1
action=$2
command=""

case $service in
"zookeeper")
  command="service zookeeper-server $action"
  ;;
esac

#remove ANSI color
$command | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit ${PIPESTATUS[0]}
