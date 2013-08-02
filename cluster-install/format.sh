echo "format namenode"

for server in cdh1 cdh2 cdh3 cdh4 ;do
	ssh -q root@$server  "
		rm -rf /hadoop/dfs/{name,data,namesecondary} /hadoop/yarn/local
		mkdir -p /hadoop/dfs/{name,data,namesecondary} /hadoop/yarn/local

		chown -R hdfs:hdfs /hadoop/dfs/name
		chmod 700 /hadoop/dfs/name

		chown -R hdfs:hdfs /hadoop/dfs/data
		chmod 700 /hadoop/dfs/data

		chown -R hdfs:hdfs /hadoop/dfs/namesecondary
		chmod 700 /hadoop/dfs/namesecondary

		chown -R yarn:yarn /hadoop/yarn/local
		chmod 700 /hadoop/yarn/local
	"
done

sh start.sh stop
su -s /bin/bash hdfs -c 'yes Y | hadoop namenode -format >> /tmp/nn.format.log 2>&1'

service hadoop-hdfs-namenode start

sleep 5

echo "mkdir,chmod,chown hadoop dir"

su -s /bin/bash hdfs -c "hadoop fs -chmod a+rw /"
while read dir user group perm
do
   su -s /bin/bash hdfs -c "hadoop fs -mkdir $dir && hadoop fs -chmod $perm $dir && hadoop fs -chown $user:$group $dir"
     echo "[IM_CONFIG_INFO]: ."
done << EOF
/tmp hdfs hadoop 1777 
/tmp/hadoop-yarn mapred mapred 777
/var hdfs hadoop 755 
/var/log yarn mapred 1775 
/var/log/hadoop-yarn/apps yarn mapred 1777
/hbase hbase hadoop 755
/user hdfs hadoop 777
/user/history mapred hadoop 1777
/user/root root hadoop 777
/user/hive hive hadoop 777
EOF

echo "start hadoop"
sh start.sh start


