# Creates distributed hadoop cluster with hadoop, spark, hbase, hive, kafka and zookeeper
#
# docker build --rm --no-cache -t hadoop_cluster .
#
# docker network create --driver bridge hadoop
# docker create -it -p 8088:8088 -p 50070:50070 -p 50075:50075 -p 2122:2122 --net hadoop --name namenode --hostname namenode --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode1 --net hadoop --hostname datanode1 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode2 --net hadoop --hostname datanode2 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode3 --net hadoop --hostname datanode3 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode4 --net hadoop --hostname datanode4 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode5 --net hadoop --hostname datanode5 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode6 --net hadoop --hostname datanode6 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode7 --net hadoop --hostname datanode7 --memory 1024m --cpus 2 hadoop_cluster
# docker run -itd --name datanode8 --net hadoop --hostname datanode8 --memory 1024m --cpus 2 hadoop_cluster
# docker start namenode
# docker exec -it namenode //etc//bootstrap.sh start_cluster
# docker exec -it namenode //etc//bootstrap.sh stop_cluster

FROM centos:6

MAINTAINER Mukesh OracleMukesh@rediffmail.com

USER root

ARG ROOT_HOME=/root

ARG HADOOP_VERSION=2.7.3
ARG SPARK_VERSION=2.4.0
ARG HBASE_VERSION=2.1.3
ARG TEZ_VERSION=0.9.1
ARG HIVE_VERSION=2.3.4
ARG ZOOKEEPER_VERSION=3.4.13
ARG KAFKA_VERSION=2.1.0
ARG MYSQL_VERSION=5.1.73-8.el6_8
ARG MYSQL_CONNECTOR_VERSION=5.1.47

# install dev tools
RUN yum clean all && \
    rpm --rebuilddb && \
    yum install -y curl which tar sudo openssh-server openssh-clients rsync mysql-server-${MYSQL_VERSION} && \
    yum clean all && \
    yum update -y libselinux && \
    yum clean all

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

# Set environment variables
ENV JAVA_HOME /usr/local/java
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV SPARK_HOME /usr/local/spark
ENV HBASE_HOME /usr/local/hbase
ENV TEZ_HOME /usr/local/tez
ENV TEZ_JARS /usr/local/tez:/usr/local/tez/lib/*
ENV TEZ_CONF_DIR /usr/local/tez/conf
#ENV HADOOP_CLASSPATH=/usr/local/tez/bin:/usr/local/tez/*:/usr/local/tez/lib/*:$HADOOP_CLASSPATH
ENV HIVE_HOME /usr/local/hive
ENV HIVE_AUX_JARS_PATH=/usr/local/tez
ENV ZOOKEEPER_HOME /usr/local/zookeeper
ENV KAFKA_HOME /usr/local/kafka
ENV BOOTSTRAP /etc/bootstrap.sh
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$HBASE_HOME/bin:$HIVE_HOME/bin:$ZOOKEEPER_HOME/bin:$KAFKA_HOME/bin/

# install java
RUN curl -L# https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u202-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u202b08.tar.gz | tar -xz -C /usr/local/

# install hadoop
RUN curl -L# https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar -xz -C /usr/local/

# Install Spark
RUN curl -L# https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz | tar -xzv -C /usr/local/

# Install HBase
RUN curl -L# https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz | tar -xzv -C /usr/local/

# Install MySql Connector
RUN curl -L# http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz | tar -xzv -C /usr/local/

# Install Tez
#RUN curl -L# https://www-eu.apache.org/dist/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz | tar -xzv -C /usr/local/

# Install Hive
RUN curl -L# https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz | tar -xz -C /usr/local/

# Install zookeeper
RUN curl -L# https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz | tar -xz -C /usr/local/

# Install kafka
RUN curl -L# https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.11-${KAFKA_VERSION}.tgz | tar -xz -C /usr/local/

# Remove downloaded files
RUN rm -f OpenJDK8U-jdk_x64_linux_hotspot_8u202b08.tar.gz hadoop-${HADOOP_VERSION}.tar.gz spark-${SPARK_VERSION}-bin-hadoop2.7.tgz hbase-${HBASE_VERSION}-bin.tar.gz mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz apache-tez-${TEZ_VERSION}-bin.tar.gz apache-hive-${HIVE_VERSION}-bin.tar.gz zookeeper-${ZOOKEEPER_VERSION}.tar.gz kafka_2.11-${KAFKA_VERSION}.tgz

# Create links
RUN rm -f /usr/bin/java && \
    cd /usr/local && \
    ln -s ./jdk8u202-b08 $JAVA_HOME && \
    ln -s $JAVA_HOME/bin/java /usr/bin/java && \
    ln -s ./hadoop-${HADOOP_VERSION} $HADOOP_HOME && \
    ln -s ./spark-${SPARK_VERSION}-bin-hadoop2.7 $SPARK_HOME && \
    ln -s ./hbase-${HBASE_VERSION} $HBASE_HOME && \
    ln -s ./apache-tez-${TEZ_VERSION}-bin $TEZ_HOME && \
    ln -s ./apache-hive-${HIVE_VERSION}-bin $HIVE_HOME && \
    ln -s ./zookeeper-${ZOOKEEPER_VERSION} $ZOOKEEPER_HOME && \
    ln -s ./kafka_2.11-${KAFKA_VERSION} $KAFKA_HOME

# add config files
ADD etc/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD etc/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD etc/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD etc/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD etc/hive/hive-site.xml $HIVE_HOME/conf/hive-site.xml
ADD etc/hive/hive-site.xml $SPARK_HOME/conf/hive-site.xml
ADD etc/tez/tez-site.xml $TEZ_HOME/conf/tez-site.xml
ADD etc/spark/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf
RUN rm -f $HADOOP_HOME/etc/hadoop/slaves && \
    rm -f $HBASE_HOME/conf/hbase-site.xml && \
    mv $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg && \
    cp /usr/local/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar $HIVE_HOME/lib/mysql-connector-java.jar && \
    cp /usr/local/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar $SPARK_HOME/jars/mysql-connector-java.jar
COPY etc/hadoop/slaves $HADOOP_HOME/etc/hadoop/slaves
ADD etc/hbase/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/local/java\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && \
    sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# add other files
ADD bootstrap.sh /etc/bootstrap.sh
ADD ssh_config /root/.ssh/config

# set owner and permissions
RUN chmod 600 ${ROOT_HOME}/.ssh/config && \
    chown root:root ${ROOT_HOME}/.ssh/config && \
    chown root:root /etc/bootstrap.sh && \
    chmod 700 /etc/bootstrap.sh && \
    chmod +x $HADOOP_HOME/etc/hadoop/*-env.sh && \
    adduser hdpuser && \
    echo 'hdpuser:hdppassword' | chpasswd && \
    usermod -aG wheel hdpuser && \
    echo "%wheel        ALL=(ALL)       ALL" >> /etc/sudoers

# set environment variable for all users
RUN echo 'export JAVA_HOME=/usr/local/java' >> /etc/bashrc && \
    echo 'export HADOOP_HOME=/usr/local/hadoop' >> /etc/bashrc && \
    echo 'export HADOOP_PREFIX=/usr/local/hadoop' >> /etc/bashrc && \
    echo 'export HADOOP_COMMON_HOME=/usr/local/hadoop' >> /etc/bashrc && \
    echo 'export HADOOP_HDFS_HOME=/usr/local/hadoop' >> /etc/bashrc && \
    echo 'export HADOOP_MAPRED_HOME=/usr/local/hadoop' >> /etc/bashrc && \
    echo 'export HADOOP_YARN_HOME=/usr/local/hadoop' >> /etc/bashrc && \
    echo 'export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop' >> /etc/bashrc && \
    echo 'export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop' >> /etc/bashrc && \
    echo 'export SPARK_HOME=/usr/local/spark' >> /etc/bashrc && \
    echo 'export HBASE_HOME=/usr/local/hbase' >> /etc/bashrc && \
    echo 'export TEZ_HOME=/usr/local/tez' >> /etc/bashrc && \
    echo 'export TEZ_CONF_DIR=/usr/local/tez/conf' >> /etc/bashrc && \
    echo 'export TEZ_JARS=/usr/local/tez:/usr/local/tez/lib/*' >> /etc/bashrc && \
    echo 'export HIVE_HOME=/usr/local/hive' >> /etc/bashrc && \
    echo 'export HIVE_AUX_JARS_PATH=/usr/local/tez' >> /etc/bashrc && \
#    echo 'export HADOOP_CLASSPATH=/usr/local/tez/bin:/usr/local/tez/*:/usr/local/tez/lib/*:$HADOOP_CLASSPATH' >> /etc/bashrc && \
    echo 'export ZOOKEEPER_HOME=/usr/local/zookeeper' >> /etc/bashrc && \
    echo 'export KAFKA_HOME=/usr/local/kafka' >> /etc/bashrc && \
    echo 'export BOOTSTRAP=/etc/bootstrap.sh' >> /etc/bashrc && \
    echo 'export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$HBASE_HOME/bin:$HIVE_HOME/bin:$ZOOKEEPER_HOME/bin:$KAFKA_HOME/bin' >> /etc/bashrc && \
    echo 'export SPARK_MAJOR_VERSION=2' >> /etc/bashrc

# SSHD Config
RUN sed -i "/^[^#]*UsePAM/ s/.*/#&/" /etc/ssh/sshd_config && \
    sed -i 's/RSAAuthentication no/RSAAuthentication yes/g' /etc/ssh/sshd_config && \
    echo "UsePAM no" >> /etc/ssh/sshd_config && \
    echo "Port 2122" >> /etc/ssh/sshd_config && \
    passwd -u -f root && \
    echo "Match User hdpuser" >> /etc/ssh/sshd_config && \
    echo "    PasswordAuthentication yes" >> /etc/ssh/sshd_config

# format hdfs, add libraries to hdfs, set up hive metastore
RUN $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    $HADOOP_HOME/bin/hdfs namenode -format

ADD bootstrap.sh /etc/bootstrap.sh

CMD ["/etc/bootstrap.sh", "-d"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090
# Mapred ports
EXPOSE 19888
# Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
# Spark ports
EXPOSE 4040
# Zookeeper and Kafka ports
EXPOSE 2181 9092
# Other ports
EXPOSE 49707 2122
