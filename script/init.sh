#!/bin/sh

echo -e "[INFO]:Init for manager"

SCRIPT_DIR=`dirname $0`
HOSTNAME=`hostname`
PASSWORD='redhat'
IM_CONFIG_LOGDIR=/var/log/edh

cp -r ../edh /etc/
