FROM openjdk:8-jdk-alpine

LABEL maintainer="Shaswat Dharaiya | srd22"
LABEL version="v1"

ENV DAEMON_RUN=true
ENV SPARK_VERSION=2.4.5
ENV HADOOP_VERSION=2.7.3
ENV SCALA_VERSION=2.11
ENV SCALA_HOME=/usr/share/scala

RUN apk update && \
	apk add --no-cache libc6-compat ca-certificates && \
	ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 && \
	rm -rf /var/cache/apk/*

RUN mkdir -p dataset

COPY model/ model/

VOLUME /tmp

ADD target/*.jar app.jar
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java -Djava.security.egd=file:/dev/./urandom -jar /app.jar" ]
CMD ["data/TestDataset.csv"]
