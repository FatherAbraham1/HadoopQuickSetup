hadoop-install
==============

Shell scripts to install and deploy a Cloudera Hadoop cluster on CentOS and Fedora.

# Requirement

These are required:

- expect
- rsync
- pssh

# Install

* Clone this repo.
* Config os and cdh yum repo by yourself.
* Edit some config files.

Edit `edh/conf/manager`,this file contains manager's hostname,for example:

```
	cdh1
```

Edit `edh/conf/nodes`,this file contains all hadoop node's hostnames,for example:

```
	cdh1
	cdh2
	cdh3
```

Now,you will have a three-nodes cluster to be installed.

Remember,when the two file's content is the same,it will be a single node cluster.

* Run this script,it will begin to install and deploy a cluster:

```
	sh install-and-run.sh
```

# Uninstall

Run this shell:

```
sh uninstall.sh
```

# License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
