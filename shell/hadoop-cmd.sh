#!/bin/sh

if [ $# -lt 1 ]; then
  echo "Usage: hadoop-cmd.sh start|stop|restart|status"
  exit 1
fi

action=$1

cd script
sh cluster.sh $action
