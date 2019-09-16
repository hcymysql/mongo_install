# mongo_install
MongoDB 副本集安装配置脚本

mongo_install.sh

mongod_test.cnf

percona-server-mongodb-3.6.13-3.3-centos6-x86_64.tar.gz

三个文件放在同一个目录下，例/root/soft/目录下

1）三个节点安装mongo并启动mongod进程

#/bin/bash mongo_install.sh install

2）在Primary节点配置副本集

#/bin/bash mongo_install.sh repl

3）重置删除数据目录

#/bin/bash mongo_install.sh reset


