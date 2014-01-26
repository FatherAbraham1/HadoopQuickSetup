hadoop-install
==============

Shell scripts to install and deploy a Cloudera Hadoop cluster on CentOS 6

## Usage

* Clone this repo.
* Config os and cdh yum repo.
* Update files.

Update `edh/manager.csv`,this file contains manager's hostname.

```
	vim edh/manager.csv 
	cdh1
```

Update `edh/nodes.csv`,this file contains all hadoop node's hostname.

```
	vim edh/nodes.csv 
	cdh1
	cdh2
	cdh3
```

When the two file's content is the same,it will be a single node cluster.

* Run this script:

```
	sh install.sh
```

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
