#!/bin/sh
umask 0022

SCRIPT_DIR=`dirname $0`
HOSTNAME=`hostname`
PASSWORD='redhat'
IM_CONFIG_LOGDIR=/var/log/edh

echo -e "Init for Apache Hadoop Software..."

cp -r ../edh /etc/
