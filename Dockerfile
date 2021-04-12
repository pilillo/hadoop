ARG BASE_CONTAINER=openjdk:8-slim

FROM ${BASE_CONTAINER} as base

ARG HADOOP_VERSION=3.2.2
ARG HADOOP_DOWNLOAD_URL=https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

ARG HADOOP_USER=hadoop
ARG HADOOP_UID=185
ARG INSTALLATION_DIR="/opt"

ENV HADOOP_HOME="${INSTALLATION_DIR}/hadoop"
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH=$HADOOP_HOME/bin/:$PATH

RUN apt-get update \
    && apt-get install -y curl --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
    && useradd -u ${HADOOP_UID} ${HADOOP_USER} \
    && chgrp root /etc/passwd && chmod ug+rw /etc/passwd

RUN curl $HADOOP_DOWNLOAD_URL | tar xvz -C ${INSTALLATION_DIR} \
	&& ln -s ${INSTALLATION_DIR}/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
	&& rm -r ${HADOOP_HOME}/share/doc

# in the share/hadoop/tools/lib there are clients to various data lakes (gcp, azure, alibaba, etc.)
# add a link to the common lib in order to add them to the classpath
RUN ln -s ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-* ${HADOOP_HOME}/share/hadoop/common/lib/

WORKDIR ${HADOOP_HOME}
RUN chmod g+w ${HADOOP_HOME}
RUN chmod a+x ${HADOOP_HOME}/bin \
    && chmod a+x ${HADOOP_HOME}/sbin

USER ${HADOOP_USER}