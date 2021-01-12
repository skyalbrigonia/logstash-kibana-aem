FROM tomcat:8.5.42-jdk8

ARG WAR_FILE
ARG MEMCACHE_HOST

#Tomcat Configuration
RUN rm -rf /usr/local/tomcat/webapps/*
RUN echo "networkaddress.cache.negative.ttl=10" >> /usr/local/openjdk-8/jre/lib/security/java.security
COPY build_resources/elastic-apm-agent-1.10.0.jar /usr/local/tomcat/elastic-apm-agent.jar
COPY build_resources/OJDBC-Full/*.jar /usr/local/tomcat/lib/
COPY build_resources/mail.jar /usr/local/tomcat/lib/mail.jar
RUN  mkdir -p /usr/local/telegraf
COPY build_resources/telegraf/* /usr/local/telegraf/
COPY build_resources/conf/start.sh /usr/local/
COPY build_resources/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY build_resources/context.xml /usr/local/tomcat/conf/context.xml
COPY build_resources/server.xml /usr/local/tomcat/conf/server.xml
COPY $WAR_FILE /usr/local/tomcat/webapps/PeterWitt.war

RUN  mkdir -p /data && \
    mkdir -p /data/logs/PeterWitt && \
    mkdir -p /data/logs/SOAPMessage
COPY build_resources/conf/ /data/conf
RUN rm -rf /data/conf/PeterWitt/memcached.properties
COPY build_resources/conf/PeterWitt/memcached.properties_dev /data/conf/PeterWitt/memcached.properties
RUN sed -i -r "s/AWS_MEMCACHE_HOST/$MEMCACHE_HOST/g" /data/conf/PeterWitt/memcached.properties

CMD ["catalina.sh", "run"]
