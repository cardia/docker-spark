FROM ubuntu:18.04

ARG ZEPPELIN_VERSION="0.8.1"
ARG SPARK_VERSION="2.3.3"
ARG HADOOP_VERSION="2.7"

LABEL maintainer "mirkoprescha"
LABEL zeppelin.version=${ZEPPELIN_VERSION}
LABEL spark.version=${SPARK_VERSION}
LABEL hadoop.version=${HADOOP_VERSION}

# Install Java and some tools
RUN apt-get -y update &&\
    apt-get -y install curl less &&\
    apt-get -y install vim &&\
    apt-get -y install openjdk-8-jdk;

RUN apt-get -y install python3 &&\
    apt-get -y install python3-pip

RUN pip3 install awscli
RUN pip3 install pyspark

##########################################
# SPARK
##########################################
ARG SPARK_ARCHIVE=http://mirror.apache-kr.org/spark/spark-2.3.3/spark-2.3.3-bin-hadoop2.7.tgz
RUN mkdir /usr/local/spark &&\
    mkdir /tmp/spark-events    # log-events for spark history server
ENV SPARK_HOME /usr/local/spark

ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -s ${SPARK_ARCHIVE} | tar -xz -C  /usr/local/spark --strip-components=1

COPY spark-defaults.conf ${SPARK_HOME}/conf/



##########################################
# Zeppelin
##########################################
RUN mkdir /usr/zeppelin &&\
    curl -s http://mirror.apache-kr.org/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz | tar -xz -C /usr/zeppelin

RUN echo '{ "allow_root": true }' > /root/.bowerrc

ENV ZEPPELIN_PORT 8080
EXPOSE $ZEPPELIN_PORT

ENV ZEPPELIN_HOME /usr/zeppelin/zeppelin-${ZEPPELIN_VERSION}-bin-all
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook

RUN mkdir -p $ZEPPELIN_HOME \
  && mkdir -p $ZEPPELIN_HOME/logs \
  && mkdir -p $ZEPPELIN_HOME/run


# my WorkDir
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN mkdir /work
WORKDIR /work
RUN mkdir /work/python
VOLUME /work/python

ENTRYPOINT  /usr/local/spark/sbin/start-history-server.sh; $ZEPPELIN_HOME/bin/zeppelin-daemon.sh start  && bash

