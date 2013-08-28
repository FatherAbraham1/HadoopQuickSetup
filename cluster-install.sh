if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

PASSWORD='redhat'

mkdir -p /etc/edh
cp -r edh/* /etc/edh/

cd scripts

sh initvar.sh
if [ "$?" != "0" ]; then
	exit 1
fi

sh install_manager.sh

if [ "$?" != "0" ]; then
	exit 1
fi

if [ -f /etc/edh/role.csv ]; then
    	NODELIST="`cat /etc/edh/role.csv | sed 's/,.*//g'`"
else
	echo "ERROR: Can not found role configuration file /etc/edh/role.csv"
	exit 1
fi

for node in $NODELIST ;do
	expect ssh_nopassword.exp $node $PASSWORD >/dev/null 2>&1
done

sh install_client.sh

cd ..

cp -u conf-template/hadoop/conf/* /etc/hadoop/conf
cp -u conf-template/hive/conf/* /etc/hive/conf
cp -u conf-template/hbase/conf/* /etc/hbase/conf
cp -u conf-template/zookeeper/conf/* /etc/zookeeper/conf

HOSTNAME=`hostname`

sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hive/conf/hive-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/hbase-site.xml

sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/slaves
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/regionservers

for node in $NODELIST ;do
	echo "ssh to $node and mkdir , init zookeeper :myid=$myid"
	ssh -q root@$server  "
		rm -rf /hadoop/dfs /var/lib/zookeeper
		mkdir -p /hadoop/dfs/{name,data,namesecondary} 
		chown -R hdfs:hdfs /hadoop/dfs && chmod -R 755 /hadoop/dfs/

		mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 755 /var/lib/zookeeper

		service zookeeper-server init --myid=1
	"

	scp -q /etc/hadoop/conf/* root@$node:/etc/hadoop/conf
	scp -q /etc/hbase/conf/* root@$node:/etc/hbase/conf
	scp -q /etc/hive/conf/* root@$node:/etc/hive/conf
	scp -q /etc/zookeeper/conf/* root@$node:/etc/zookeeper/conf
done


sh start.sh stop
su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'

service hadoop-hdfs-namenode start
sleep 5


echo "[INFO]:create hdfs dir"

su -s /bin/bash hdfs -c "hadoop fs -chmod a+rw /"
while read dir user group perm
do
   su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
     echo "[INFO]: ."
done << EOF
/hbase hbase hadoop 755
/tmp hdfs hadoop 1777 
/tmp/hadoop-yarn mapred mapred 777
/var hdfs hadoop 755 
/var/log yarn mapred 1775 
/var/log/hadoop-yarn/apps yarn mapred 1777
/yarn/apps yarn mapred 1777
/user hdfs hadoop 777
/user/root root hadoop 755
/user/hive hive hadoop 775
/user/hive/warehouse hive hadoop 775
/user/history mapred hadoop 1777 
EOF

echo "[INFO]:install postgres"
sh install-postgres.sh

echo "[INFO]:start hadoop"
sh start.sh start

echo "[INFO]:patch"
cd patch
sh patch1.sh
