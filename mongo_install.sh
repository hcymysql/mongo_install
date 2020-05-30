# MongoDB 3.6副本集安装配置脚本
#!/bin/bash

### 修改下面的变量值 ###
#####################################################
mongodb_version=percona-server-mongodb-3.6.14-3.4-centos6-x86_64.tar.gz
mongodb_version_dir=percona-server-mongodb-3.6.14-3.4
dbport=27017
replSet=test_rs1 #副本集名字
dbname=test1
wiredTigerCacheSizeGB=1 #物理内存70%

primary=192.168.0.1
secondary1=192.168.0.2
secondary2=192.168.0.3

dns1=test1.mongodb.dc.hechunyang.com
dns2=test2.mongodb.dc.hechunyang.com
dns3=test3.mongodb.dc.hechunyang.com

###以下不用改###
#####################################################

if [ "$1" = "install" ]
then

cat << EOF >> /etc/hosts

$primary	$dns1
$secondary1	$dns2
$secondary2	$dns3

EOF

echo "正在安装MongoDB软件......."

useradd mongodb

sleep 2

ps aux | grep 'mongodb' | grep -v 'grep' | grep -v 'bash'
if [ $? -eq 0 ]
then
	echo "MongoDB进程已经启动，无需二次安装。"
	exit 0
fi

if [ ! -d /usr/local/${mongodb_version_dir} ]
then
	tar zxvf ${mongodb_version} -C /usr/local/
	ln -s /usr/local/${mongodb_version_dir} /usr/local/mongodb
	chown -R mongodb.mongodb /usr/local/mongodb/
	chown -R mongodb.mongodb /usr/local/mongodb
else
	ln -s /usr/local/${mongodb_version_dir} /usr/local/mongodb
	chown -R mongodb.mongodb /usr/local/mongodb/
	chown -R mongodb.mongodb /usr/local/mongodb
fi 

sed "s/test/$dbname/;s/27017/$dbport/;s/test_rs1/$replSet/;/wiredTigerCacheSizeGB/s/30/$wiredTigerCacheSizeGB/" mongod_test.cnf > /etc/mongod_$dbname.cnf

    	mkdir -p /data/mongodb/$dbname/{data,logs,key}
	echo -e "my secret key" > /data/mongodb/$dbname/key/mongodb-keyfile
    	chmod 600 /data/mongodb/$dbname/key/mongodb-keyfile  
	chown -R mongodb.mongodb /data/mongodb/
    
	su - mongodb -c "/usr/bin/numactl --interleave=all /usr/local/mongodb/bin/mongod -f /etc/mongod_$dbname.cnf"
	
	sleep 5
	ps aux | grep 'mongodb' | grep -v 'grep' | grep -v 'bash'
	if [ $? -eq 0 ]
	then
        		echo "MongoDB安装完毕。"
	else
		echo "MongoDB安装失败。"
	fi

sed -i -r "s/(PATH=)/\1\/usr\/local\/mongodb\/bin:/" /root/.bash_profile
source /root/.bash_profile
exit 0
fi

############################
if [ "$1" = "repl" ]
then
/usr/local/mongodb/bin/mongo localhost:$dbport/admin <<EOF

use admin
config_rs = {
_id:'${replSet}',
members:[
{_id:0,host:'${dns1}:$dbport'},
{_id:1,host:'${dns2}:$dbport'},
{_id:2,host:'${dns3}:$dbport'},
]
}
rs.initiate(config_rs)
EOF

sleep 2
###创建超级管理员账号
/usr/local/mongodb/bin/mongo localhost:$dbport/admin --quiet --eval 'db.createUser({user:"admin",pwd:"hechunyang",roles:[{role:"root",db:"admin"}]})'

echo "MongoDB副本集和账号初始化完毕。"

fi

#########################################
if [ "$1" = "reset" ]
then
        pkill -9 mongo
        rm -rf /data/mongodb/$dbname  ##想好了再干
        exit
fi

