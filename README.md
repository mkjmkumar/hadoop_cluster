Hadoop cluster using Docker
==========
This repository contains Docker file to build a Docker image with Hadoop, Spark, HBase, Hive, Zookeeper and Kafka. The accompanying scripts can be used to start and stop the clusters easily.

## Pull the image docker hub

The image is released as Public Docker image from Docker Hub - you can always pull or refer the image when launching containers.
```
docker pull mukeshkumarmavenwavecom/hadoop_cluster
```

## Build the image downloaded from docker hub

If you would like to try directly from the Dockerfile you can build the image as:
```
docker build --rm --no-cache -t mukeshkumarmavenwavecom/hadoop_cluster .
```
## Pull docker file from github

git clone https://github.com/mkjmkumar/hadoop_cluster.git

## go to dockerfile folder 

cd mkjmkumar

## Build the image from docker file

docker build --rm --no-cache -t hadoop_cluster .

# Create network, containers and start cluster

## Through script
You can use the start_cluster.sh and stop_cluster.sh scripts to start and stop the hadoop cluster using bash or Windows Powershell.
* Default is 1 namenode with 2 datanodes (upto 8 datanodes currently possible, to add more edit "/usr/local/hadoop/etc/hadoop/slaves" and restart the cluster)
* Each node takes 1GB memory and 2 virtual cpu cores
```
sh start_cluster.sh 2
sh stop_cluster.sh
```

## Manual procedure
### Create bridge network
```
docker network create --driver bridge hadoop
```
### Create and start containers
Create a namenode container with the Docker image you have just built or pulled
```
docker create -it -p 8088:8088 -p 50070:50070 -p 50075:50075 -p 2122:2122  --net hadoop --name namenode --hostname namenode --memory 1024m --cpus 2 hadoop_cluster
```
Create and start datanode containers with the Docker image you have just built or pulled (upto 8 datanodes currently possible, to add more edit "/usr/local/hadoop/etc/hadoop/slaves" and restart the cluster)
```
docker run -itd --name datanode1 --net hadoop --hostname datanode1 --memory 1024m --cpus 2 hadoop_cluster
docker run -itd --name datanode2 --net hadoop --hostname datanode2 --memory 1024m --cpus 2 hadoop_cluster
...
```
### Start datanode container(In my case I am running two data node cluster)
```
docker start datanode1
docker start datanode2
```

### Start namenode container
```
docker start namenode
```
### Grab IP Address of datanodes using below command on each datanode
```
docker exec -it datanode1 cat /etc/hosts
172.18.0.2
docker exec -it datanode2 cat /etc/hosts
172.18.0.3
```
### Update namenode slaves entryto run cluster
```
docker exec -it namenode bash
vi /usr/local/hadoop/etc/hadoop/slaves
172.18.0.2
172.18.0.3
```
### Start cluster
```
docker exec -it namenode /etc/bootstrap.sh start_cluster

Starting mysqld:                                           [  OK  ]
ZooKeeper JMX enabled by default
Using config: /usr/local/zookeeper/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
Starting namenodes on [namenode]
namenode: starting namenode, logging to /usr/local/hadoop/logs/hadoop-root-namenode-namenode.out
: starting datanode, logging to /usr/local/hadoop/logs/hadoop-root-datanode-datanode2.out
: starting datanode, logging to /usr/local/hadoop/logs/hadoop-root-datanode-datanode1.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: starting secondarynamenode, logging to /usr/local/hadoop/logs/hadoop-root-secondarynamenode-namenode.out
starting yarn daemons
starting resourcemanager, logging to /usr/local/hadoop/logs/yarn--resourcemanager-namenode.out
: starting nodemanager, logging to /usr/local/hadoop/logs/yarn-root-nodemanager-datanode2.out
: starting nodemanager, logging to /usr/local/hadoop/logs/yarn-root-nodemanager-datanode1.out
SLF4J: Class path contains multiple SLF4J bindings.
After few minutes, you should be able to view Resource Manager UI at
..
..
```
### After some time you should be able to browse the cluster from URI
```
http://localhost:8088
```
You should be able to access the HDFS UI at
```
http://localhost:50070

## Credentials
You can connect through SSH and SFTP clients to the namenode of the cluster using port 2122
```
Username: hdpuser
Password: hdppassword
```

### Miscellaneous information
* You can login as root user into namenode using "docker exec -it namenode bash"
* To start HBase manually, log in as root (as described above) and executing the command "$HBASE_HOME/bin/start-hbase.sh"
* To start Kafka manually, log in as root (as described above) and executing the command "$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties"
* Kafka topics can be created by "hdpuser" with root priviledges
```
sudo $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper namenode:2181 --replication-factor 1 --partitions 1 --topic test

$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper namenode:2181 --replication-factor 1 --partitions 3 --topic msgtopic

$KAFKA_HOME/bin/kafka-console-producer.sh --broker-list namenode:9092 --topic msgtopic

$KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server namenode:9092 --topic msgtopic --from-beginning
```
### Known issues
* Spark application master is not reachable from host system
* HBase and Kafka services do not start automatically sometimes (increasing memory of the container might solve this issue)
* No proper PySpark setup
* Unable to get Hive to work on Tez (current default MapReduce)
