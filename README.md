hadoop-install
==============


## Overview

	.
	├── all-in-one-install.sh
	├── cluster-install.sh
	├── command.sh
	├── edh
	├── patch
	├── README.md
	├── script
	└── uninstall.sh

	3 directories, 5 files


* all-in-one-install.sh: install hadoop in one node
* cluster-install.sh: install hadoop in a cluster

## How to use

* all-in-one-install

Run this commands:

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



 
