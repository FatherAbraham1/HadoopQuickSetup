#!/bin/sh
 

    #format namenode
    echo "[IM_CONFIG_PROCESS]: formatting hdfs namenode ..."
    su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'
    if [ "$?" != "0" ]; then
        echo "[IM_CONFIG_ERROR]: Error: Failed to format namenode!"
        exit 1
    fi
    if [ "" != "" ]; then 
        ifconfig lo:0  netmask 255.255.255.255 up
    fi 
    #create hdfs dirs
    service hadoop-namenode start >/dev/null 2>/dev/null

    echo "[IM_CONFIG_INFO]: waiting namenode starting..."
    count=0
    while [ "1" == "1" ]
    do
        sleep 5
        service  hadoop-namenode  status >/dev/null 2>/dev/null 
        if [ "$?" == "0" ]; then
            echo "[IM_CONFIG_INFO]: namenode has started..."
            break;
        fi
        (( count = count+5 ))
        if [ $count -ge 300 ]; then
            echo "[IM_CONFIG_ERROR]: Can not start namenode, skipping..."
            break;
        fi
    done

    echo "[IM_CONFIG_PROCESS]: check hdfs for writing ..."
    while [ "1" == "1" ]
    do 
        sleep 5 
        service  hadoop-namenode  status >/dev/null 2>/dev/null 
        if [ "$?" != "0" ]; then 
            echo "[IM_CONFIG_ERROR]: Error: Namenode has stopped!"
            break; 
        fi

              su -s /bin/bash hdfs -c "hadoop fs -mkdir /testforwriting"
              if [ "$?" == "0" ]; then 
            break
        else 
            echo "..."
        fi 
    done  
      su -s /bin/bash hdfs -c "hadoop fs -rmr /testforwriting >/dev/null 2>/dev/null"
      if [ "$?" == "0" ]; then 
        echo "[IM_CONFIG_INFO]: check successfully"
    else 
        echo "[IM_CONFIG_ERROR]: error happened in check"
    fi
    echo "[IM_CONFIG_PROCESS]: creating basic hdfs directory for system"
      su -s /bin/bash hdfs -c "hadoop fs -chmod a+rw /"
      while read dir user group perm
    do
           su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
             echo "[IM_CONFIG_INFO]: ."
    done << EOF
    /hbase hbase hbase 755
    /hbck hbase hbase 755
    /mapred mapred hadoop 755
    /mapred/system mapred hadoop 700
    /tmp hdfs hadoop 777 
    /tmp/hadoop-mapred mapred hadoop 777 
    /tmp/hadoop-mapred/mapred mapred hadoop 777 
    /tmp/hadoop-mapred/mapred/staging mapred hadoop 777 
    /tmp/hadoop-mapred/mapred/temp mapred hadoop 777 
    /tmp/hive hive hadoop 777
    /user hdfs hadoop 777
    /user/root root hadoop 755
    /user/hive hive hadoop 755 
    /user/hive/warehouse hive hadoop 777
EOF

    #stop namenode service
    echo "[IM_CONFIG_INFO]: stop namenode service"
    service hadoop-namenode stop >/dev/null 2>/dev/null

    #initialize hive metastore
          #start mysql service
      service  mysqld restart

      mysql -f << EOF
CREATE DATABASE IF NOT EXISTS metastore;
USE metastore;
GRANT SELECT,INSERT,UPDATE,DELETE ON metastore.* TO 'hiveuser'@'%' IDENTIFIED BY 'password';
REVOKE ALTER,CREATE ON metastore.* FROM 'hiveuser'@'%';
SOURCE /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.9.0.mysql.sql;
GRANT USAGE ON *.* TO ''@'desktop30';
DROP USER ''@'desktop30';
DELETE FROM mysql.user WHERE user = '' and host = 'desktop30';
GRANT USAGE ON *.* TO ''@'localhost';
DROP USER ''@'localhost';
DELETE FROM mysql.user WHERE user = '' and host = 'localhost';
UPDATE mysql.user SET password = PASSWORD('password') WHERE user = 'root' AND password = '';
FLUSH PRIVILEGES;
EOF
 
      service  mysqld stop
     

    if [ "" != "" ]; then 
        ifconfig lo:0  netmask 255.255.255.255 down
    fi 

#stop drbd
