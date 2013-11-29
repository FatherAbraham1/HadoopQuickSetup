#!/bin/sh
#usage: hive-metastore-service [start|stop|restart|status]
command=$1
  case "$command" in
    start)
      service mysqld start
      service hive-metastore start
      ;;
    stop)
      service hive-metastore stop
      service mysqld stop
      ;;
    status)
      service mysqld status
      service hive-metastore status
      ;;
    restart)
      service mysqld restart
      service hive-metastore restart
      ;;
  esac
