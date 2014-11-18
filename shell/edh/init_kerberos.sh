#!/bin/bash

DNS=JAVACHEN.COM

for host in  `cat /etc/hosts|grep 192.168|awk '{print $2}'` ;do
  for user in hdfs HTTP yarn mapred hive impala sentry zookeeper zkcli; do
    kadmin.local -q "addprinc -randkey $user/$host@$DNS"
    kadmin.local -q "xst -k /var/kerberos/krb5kdc/$user-unmerged.keytab $user/$host@$DNS"
  done
done
