#!/bin/sh
#usage: hbase-service [master|regionserver|thrift|thrift-kerberos] [start|stop|restart|status|force-stop]
service=$1
action=$2
command=""

case $service in
"master")
  command="service hbase-master $action"
  ;;
"regionserver")
  command="service hbase-regionserver $action"
  ;;
"thrift")
  command="service hbase-thrift $action"
  ;;
"thrift-kerberos")
  command="fqdn=\`hostname -f\`; su -s /bin/sh hbase -c \"kinit -kt /etc/hbase.keytab hbase/\$fqdn\"; service hbase-thrift $action" 
  ;;
esac

#remove ANSI color
bash -c "$command" | perl -pe 's/\r|\e\[?.*?[\@-~]//g';  exit ${PIPESTATUS[0]}
