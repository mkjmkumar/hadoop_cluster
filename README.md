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
## Build Manually using DockerFile from my github repo
## Pull docker file from github
```
git clone https://github.com/mkjmkumar/hadoop_cluster.git
```
## go to dockerfile folder 
```
cd hadoop_cluster
```
## Build the image from docker file
```
docker build --rm --no-cache -t hadoop_cluster .
```
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
docker create -it -p 8088:8088 -p 50070:50070 -p 50075:50075 -p 2122:2122 -p 7077:7077 -p 8081:8081 -p 8080:8080 --net hadoop --name namenode --hostname namenode --memory 1024m --cpus 2 hadoop_cluster
```
Create and start datanode containers with the Docker image you have just built or pulled (upto 8 datanodes currently possible, to add more edit "/usr/local/hadoop/etc/hadoop/slaves" and restart the cluster)
```
docker run -itd --name datanode1 --net hadoop --hostname datanode1 --memory 1024m --cpus 2 hadoop_cluster
docker run -itd --name datanode2 --net hadoop --hostname datanode2 --memory 1024m --cpus 2 hadoop_cluster
...
```
Start datanode container(In my case I am running two data node cluster)
```
docker start datanode1
docker start datanode2
```
Start namenode container
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
```
After few minutes, you should be able to view Resource Manager UI at
..
..
```
### After some time you should be able to browse the cluster from URI
```
http://localhost:8088

You should be able to access the HDFS UI at

http://localhost:50070

You should be able to access the SPark Master WebUI at
http://localhost:8080/

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

$KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper namenode:2181 --replication-factor 3 --partitions 1 --topic mukeshtopic
```

### List TOPIC
```
$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper namenode:2181
```
### Describe a TOPIC
```
$KAFKA_HOME/bin/kafka-topics.sh --zookeeper  namenode:2181 --describe --topic mukeshtopic
```

$KAFKA_HOME/bin/kafka-configs.sh --zookeeper namenode:2181 --describe --entity-name mukeshtopic --entity-type topics



### Delete TOPIC
```
$KAFKA_HOME/bin/kafka-topics.sh --delete --zookeeper namenode:2181 --topic mukeshtopic
```
### Use case : Delete Topic
METHOD 1 : Delete Topic and recreate it.
Follow above commands to delete and create a topic again.

METHOD2 : Alter Topic retention period to milliseconds and Alter Back to original
Check Retension period
```
$KAFKA_HOME/bin/kafka-configs.sh --zookeeper namenode:2181 --describe --entity-type topics --entity-name mukeshtopic
```
Set Retension period
# Deprecated way
```
$KAFKA_HOME/bin/kafka-topics.sh --zookeeper namenode:2181 --alter --topic mukeshtopic --config retention.ms=1000
```
# Modern way
$KAFKA_HOME/bin/kafka-configs.sh --zookeeper namenode:2181 --alter --entity-type topics --entity-name mukeshtopic --add-config retention.ms=2000

METHOD3 : Goto Topic Folder and delete all Segments
### Describe a topic
```
$KAFKA_HOME/bin/kafka-topics.sh --describe --zookeeper namenode:2181 --topic mukeshtopic
```
### Add a partition
```
$KAFKA_HOME/bin/kafka-topics.sh --alter --zookeeper namenode:2181 --topic mukeshtopic --partitions 4
```
### Push a file of messages to Kafka
```
$KAFKA_HOME/bin/kafka-console-producer.sh --broker-list namenode:9092 --topic mukeshtopic < zookeeper.out
```
### Get the earliest offset still in a topic
```
$KAFKA_HOME/bin/kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list namenode:9092 --topic mukeshtopic --time -2
```
### Running PySpark in Local Mode 
```
pyspark local[2]
```
### Running PySpark in Spark Master Mode
```
pyspark --master spark://namenode:7077
```
### In Case you face any issue starting when Spark Master and Worker are not running(Use jps command to verify), use below command to start Spark Manually  
```
cd $SPARK_HOME/sbin
./start-all.sh
```
### To Add additional worker Manually 
```
Worker on Master Node
./start-slave.sh spark://namenode:7077
Additional Workers 
cp slaves.template slaves

Add worker list in slaves file
```

### To view Spark UI 

```
http://localhost:8080/
```

### Connect to Spark with MySQL Database(Local)
```
from pyspark.sql import SQLContext
sqlContext = SQLContext(sc)
dataframe_mysql = sqlContext.read.format("jdbc").options(url="jdbc:mysql://localhost/information_schema",driver = "com.mysql.jdbc.Driver",dbtable = "TABLES",user="root").load()
>>> dataframe_mysql.show(10)
+-------------+------------------+--------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
|TABLE_CATALOG|      TABLE_SCHEMA|          TABLE_NAME| TABLE_TYPE|ENGINE|VERSION|ROW_FORMAT|TABLE_ROWS|AVG_ROW_LENGTH|DATA_LENGTH|MAX_DATA_LENGTH|INDEX_LENGTH|DATA_FREE|AUTO_INCREMENT|        CREATE_TIME|        UPDATE_TIME|CHECK_TIME|TABLE_COLLATION|CHECKSUM|CREATE_OPTIONS|TABLE_COMMENT|
+-------------+------------------+--------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
|         null|information_schema|      CHARACTER_SETS|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|           384|          0|       16434816|           0|        0|          null|2020-03-16 19:17:29|               null|      null|utf8_general_ci|    null|max_rows=43690|             |
| 
```

### Print Schema 
```


>>> df_mysql.printSchema()
root
 |-- TABLE_CATALOG: string (nullable = true)
 |-- TABLE_SCHEMA: string (nullable = true)
 |-- TABLE_NAME: string (nullable = true)
 |-- TABLE_TYPE: string (nullable = true)
 |-- ENGINE: string (nullable = true)
 |-- VERSION: decimal(20,0) (nullable = true)
 |-- ROW_FORMAT: string (nullable = true)
 |-- TABLE_ROWS: decimal(20,0) (nullable = true)
 |-- AVG_ROW_LENGTH: decimal(20,0) (nullable = true)
 |-- DATA_LENGTH: decimal(20,0) (nullable = true)
 |-- MAX_DATA_LENGTH: decimal(20,0) (nullable = true)
 |-- INDEX_LENGTH: decimal(20,0) (nullable = true)
 |-- DATA_FREE: decimal(20,0) (nullable = true)
 |-- AUTO_INCREMENT: decimal(20,0) (nullable = true)
 |-- CREATE_TIME: timestamp (nullable = true)
 |-- UPDATE_TIME: timestamp (nullable = true)
 |-- CHECK_TIME: timestamp (nullable = true)
 |-- TABLE_COLLATION: string (nullable = true)
 |-- CHECKSUM: decimal(20,0) (nullable = true)
 |-- CREATE_OPTIONS: string (nullable = true)
 |-- TABLE_COMMENT: string (nullable = true)
```

### Predicate push down in Spark 
```
>>> df_mysql.show(10, truncate=False)
+-------------+------------------+-------------------------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
|TABLE_CATALOG|TABLE_SCHEMA      |TABLE_NAME                           |TABLE_TYPE |ENGINE|VERSION|ROW_FORMAT|TABLE_ROWS|AVG_ROW_LENGTH|DATA_LENGTH|MAX_DATA_LENGTH|INDEX_LENGTH|DATA_FREE|AUTO_INCREMENT|CREATE_TIME        |UPDATE_TIME        |CHECK_TIME|TABLE_COLLATION|CHECKSUM|CREATE_OPTIONS|TABLE_COMMENT|
+-------------+------------------+-------------------------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
|null         |information_schema|CHARACTER_SETS                       |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |384           |0          |16434816       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=43690|             |
|null         |information_schema|COLLATIONS                           |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |231           |0          |16704765       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=72628|             |
|null         |information_schema|COLLATION_CHARACTER_SET_APPLICABILITY|SYSTEM VIEW|MEMORY|10     |Fixed     |null      |195           |0          |16357770       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=86037|             |
|null         |information_schema|COLUMNS                              |SYSTEM VIEW|MyISAM|10     |Dynamic   |null      |0             |0          |281474976710655|1024        |0        |null          |2020-06-12 05:51:50|2020-06-12 05:51:50|null      |utf8_general_ci|null    |max_rows=4560 |             |
|null         |information_schema|COLUMN_PRIVILEGES                    |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |2565          |0          |16757145       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=6540 |             |
|null         |information_schema|ENGINES                              |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |490           |0          |16574250       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=34239|             |
|null         |information_schema|EVENTS                               |SYSTEM VIEW|MyISAM|10     |Dynamic   |null      |0             |0          |281474976710655|1024        |0        |null          |2020-06-12 05:51:50|2020-06-12 05:51:50|null      |utf8_general_ci|null    |max_rows=618  |             |
|null         |information_schema|FILES                                |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |2677          |0          |16758020       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=6267 |             |
|null         |information_schema|GLOBAL_STATUS                        |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |3268          |0          |16755036       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=5133 |             |
|null         |information_schema|GLOBAL_VARIABLES                     |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |3268          |0          |16755036       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=5133 |             |
+-------------+------------------+-------------------------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
only showing top 10 rows

>>> df_mysql.show(10, truncate=False)
+-------------+------------------+-------------------------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
|TABLE_CATALOG|TABLE_SCHEMA      |TABLE_NAME                           |TABLE_TYPE |ENGINE|VERSION|ROW_FORMAT|TABLE_ROWS|AVG_ROW_LENGTH|DATA_LENGTH|MAX_DATA_LENGTH|INDEX_LENGTH|DATA_FREE|AUTO_INCREMENT|CREATE_TIME        |UPDATE_TIME        |CHECK_TIME|TABLE_COLLATION|CHECKSUM|CREATE_OPTIONS|TABLE_COMMENT|
+-------------+------------------+-------------------------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
|null         |information_schema|CHARACTER_SETS                       |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |384           |0          |16434816       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=43690|             |
|null         |information_schema|COLLATIONS                           |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |231           |0          |16704765       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=72628|             |
|null         |information_schema|COLLATION_CHARACTER_SET_APPLICABILITY|SYSTEM VIEW|MEMORY|10     |Fixed     |null      |195           |0          |16357770       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=86037|             |
|null         |information_schema|COLUMNS                              |SYSTEM VIEW|MyISAM|10     |Dynamic   |null      |0             |0          |281474976710655|1024        |0        |null          |2020-06-12 05:51:50|2020-06-12 05:51:50|null      |utf8_general_ci|null    |max_rows=4560 |             |
|null         |information_schema|COLUMN_PRIVILEGES                    |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |2565          |0          |16757145       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=6540 |             |
|null         |information_schema|ENGINES                              |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |490           |0          |16574250       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=34239|             |
|null         |information_schema|EVENTS                               |SYSTEM VIEW|MyISAM|10     |Dynamic   |null      |0             |0          |281474976710655|1024        |0        |null          |2020-06-12 05:51:50|2020-06-12 05:51:50|null      |utf8_general_ci|null    |max_rows=618  |             |
|null         |information_schema|FILES                                |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |2677          |0          |16758020       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=6267 |             |
|null         |information_schema|GLOBAL_STATUS                        |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |3268          |0          |16755036       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=5133 |             |
|null         |information_schema|GLOBAL_VARIABLES                     |SYSTEM VIEW|MEMORY|10     |Fixed     |null      |3268          |0          |16755036       |0           |0        |null          |2020-06-12 05:51:50|null               |null      |utf8_general_ci|null    |max_rows=5133 |             |
+-------------+------------------+-------------------------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-------------------+----------+---------------+--------+--------------+-------------+
only showing top 10 rows
>>> df_mysql.filter((col('ROW_FORMAT') == 'Fixed') & (col('AVG_ROW_LENGTH') > 3000)).show()
+-------------+------------------+--------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-----------+----------+---------------+--------+--------------+-------------+
|TABLE_CATALOG|      TABLE_SCHEMA|          TABLE_NAME| TABLE_TYPE|ENGINE|VERSION|ROW_FORMAT|TABLE_ROWS|AVG_ROW_LENGTH|DATA_LENGTH|MAX_DATA_LENGTH|INDEX_LENGTH|DATA_FREE|AUTO_INCREMENT|        CREATE_TIME|UPDATE_TIME|CHECK_TIME|TABLE_COLLATION|CHECKSUM|CREATE_OPTIONS|TABLE_COMMENT|
+-------------+------------------+--------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-----------+----------+---------------+--------+--------------+-------------+
|         null|information_schema|       GLOBAL_STATUS|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          3268|          0|       16755036|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=5133|             |
|         null|information_schema|    GLOBAL_VARIABLES|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          3268|          0|       16755036|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=5133|             |
|         null|information_schema|    KEY_COLUMN_USAGE|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          4637|          0|       16762755|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=3618|             |
|         null|information_schema|REFERENTIAL_CONST...|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          4814|          0|       16767162|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=3485|             |
|         null|information_schema|            SCHEMATA|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          3464|          0|       16738048|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=4843|             |
|         null|information_schema|      SESSION_STATUS|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          3268|          0|       16755036|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=5133|             |
|         null|information_schema|   SESSION_VARIABLES|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          3268|          0|       16755036|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=5133|             |
|         null|information_schema|              TABLES|SYSTEM VIEW|MEMORY|     10|     Fixed|      null|          3545|          0|       16743035|           0|        0|          null|2020-06-12 05:59:12|       null|      null|utf8_general_ci|    null| max_rows=4732|             |
+-------------+------------------+--------------------+-----------+------+-------+----------+----------+--------------+-----------+---------------+------------+---------+--------------+-------------------+-----------+----------+---------------+--------+--------------+-------------+

>>> df_filter = df_mysql.filter((col('ROW_FORMAT') == 'Fixed') & (col('AVG_ROW_LENGTH') > 3000))
>>> df_filter.explain()
== Physical Plan ==
*(1) Scan JDBCRelation(TABLES) [numPartitions=1] [TABLE_CATALOG#0,TABLE_SCHEMA#1,TABLE_NAME#2,TABLE_TYPE#3,ENGINE#4,VERSION#5,ROW_FORMAT#6,TABLE_ROWS#7,AVG_ROW_LENGTH#8,DATA_LENGTH#9,MAX_DATA_LENGTH#10,INDEX_LENGTH#11,DATA_FREE#12,AUTO_INCREMENT#13,CREATE_TIME#14,UPDATE_TIME#15,CHECK_TIME#16,TABLE_COLLATION#17,CHECKSUM#18,CREATE_OPTIONS#19,TABLE_COMMENT#20] PushedFilters: [*IsNotNull(ROW_FORMAT), *IsNotNull(AVG_ROW_LENGTH), *EqualTo(ROW_FORMAT,Fixed), *GreaterThan(AVG..., ReadSchema: struct<TABLE_CATALOG:string,TABLE_SCHEMA:string,TABLE_NAME:string,TABLE_TYPE:string,ENGINE:string...
>>> df_filter = df_mysql.filter(((col('AVG_ROW_LENGTH') > 3000))
... )
```

### Notice the Pushed Filter Above Explain Command
```
PushedFilters: [*IsNotNull(ROW_FORMAT), *IsNotNull(AVG_ROW_LENGTH), *EqualTo(ROW_FORMAT,Fixed), *GreaterThan(AVG...
```


### 
```

```
### Known issues
* Spark application master is not reachable from host system
* HBase and Kafka services do not start automatically sometimes (increasing memory of the container might solve this issue) or (In case Hbase is throwing error "ERROR: KeeperErrorCode = NoNode for /hbase/master", reason could be Hbase not started automatically. Therefore "/usr/local/hbase/bin/stop-hbase.sh" and "/usr/local/hbase/bin/start-hbase.sh" solve the Hbase issue.)
* No proper PySpark setup(resolved at https://www.linkedin.com/pulse/solved-starting-pyspark-generates-nameerror-name-mukesh-kumar-)
* Unable to get Hive to work on Tez (current default MapReduce)
* In case docker container Existed with EOL error then please change Windows CRLF to LF to all shell scripts, more you can find at https://willi.am/blog/2016/08/11/docker-for-windows-dealing-with-windows-line-endings/
