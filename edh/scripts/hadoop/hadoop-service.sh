#!/bin/sh
#usage: hadoop-service [namenode|datanode|secondary_namenode|jobtracker|tasktracker] [start|stop|restart|status]
service=$1
action=$2
command=""

case $service in
"namenode")
  case $action in
  "upgrade-stop")
  command="service hadoop-namenode stop"
  ;;
  *)
  command="service hadoop-namenode $action"
  ;;
  esac
  
  ;;
"datanode")
  case $action in
  "start" | "upgrade" | "rollback")
  command="service hadoop-datanode start"
  ;;
  "stop" | "upgrade-stop")
  command="service hadoop-datanode stop"
  ;;
  *)
  command="service hadoop-datanode $action"
  ;;
  esac
  ;;
"secondary_namenode")
  case $action in
  "start" | "upgrade" | "rollback")
  command="service hadoop-secondarynamenode start"
  ;;
  "stop" | "upgrade-stop")
  command="service hadoop-secondarynamenode stop"
  ;;
  *)
  command="service hadoop-secondarynamenode $action"
  ;;
  esac
  ;;
"jobtracker")
  command="service hadoop-jobtracker $action"
  ;;
"tasktracker")
  command="service hadoop-tasktracker $action"
  ;;
esac

#remove ANSI color
bash -c "$command" | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit ${PIPESTATUS[0]}
