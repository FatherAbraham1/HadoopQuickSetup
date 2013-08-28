hadoop-install
==============


## Overview

	.
	├── cluster-install
	│   ├── all-in-one-install.sh
	│   ├── cluster-install.sh
	│   ├── command.sh
	│   ├── conf-template
	│   ├── edh
	│   ├── format.sh
	│   ├── patch
	│   ├── install-postgres.sh
	│   ├── postgresql-9.1-901.jdbc4.jar
	│   ├── readme.txt
	│   ├── scripts
	│   ├── start.sh
	│   └── temp.sh
	└── README.md
	5 directories, 10 files


* all-in-one-install.sh: install hadoop in one node
* cluster-install.sh: install hadoop in a cluster

## How to use

* all-in-one-install

open all-in-one-install.sh and modify repo's baseurl:

	echo "[cloudera-cdh4]" >/etc/yum.repos.d/edh.repo
	echo "name=cdh4" >>/etc/yum.repos.d/edh.repo
	echo "baseurl=ftp://192.168.56.101/pub/cdh/4.3.0/" >>/etc/yum.repos.d/edh.repo
	echo "gpgcheck = 0" >>/etc/yum.repos.d/edh.repo

And then run this commands:

	[root@node1 cluster-install]# sh all-in-one-install.sh

Wait several seconds,run jps command and you will see:

	[root@node1 ~]# jps
	30455 RunJar
	31060 HRegionServer
	30539 RunJar
	29874 DataNode
	28843 NameNode
	31160 Jps
	29989 ResourceManager
	30380 JobHistoryServer
	30844 QuorumPeerMain
	1810 SecondaryNameNode
	30246 NodeManager

* cluster-install
Just run this comand:

	[root@node1 cluster-install]# sh cluster-install.sh

## Change

## TODO



 
