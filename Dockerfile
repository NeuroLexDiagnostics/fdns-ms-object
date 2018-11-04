# build stage
FROM maven:3-jdk-11 as builder
RUN mkdir -p /usr/src/app
COPY pom.xml /usr/src/app
WORKDIR /usr/src/app
RUN mvn dependency:resolve
COPY . /usr/src/app
RUN mvn clean package

# run stage
FROM openjdk:8-jre-alpine

ARG OBJECT_PORT
ARG OBJECT_MONGO_HOST
ARG OBJECT_MONGO_PORT
ARG OBJECT_MONGO_USER_DATABASE
ARG OBJECT_MONGO_USERNAME
ARG OBJECT_MONGO_PASSWORD
ARG OBJECT_IMMUTABLE
ARG OBJECT_FLUENTD_HOST
ARG OBJECT_FLUENTD_PORT
ARG OBJECT_PROXY_HOSTNAME
ARG OAUTH2_ACCESS_TOKEN_URI
ARG OAUTH2_PROTECTED_URIS
ARG OAUTH2_CLIENT_ID
ARG OAUTH2_CLIENT_SECRET
ARG SSL_VERIFYING_DISABLE

ENV OBJECT_PORT ${OBJECT_PORT}
ENV OBJECT_MONGO_HOST ${OBJECT_MONGO_HOST}
ENV OBJECT_MONGO_PORT ${OBJECT_MONGO_PORT}
ENV OBJECT_MONGO_USER_DATABASE ${OBJECT_MONGO_USER_DATABASE}
ENV OBJECT_MONGO_USERNAME ${OBJECT_MONGO_USERNAME}
ENV OBJECT_MONGO_PASSWORD ${OBJECT_MONGO_PASSWORD}
ENV OBJECT_IMMUTABLE ${OBJECT_IMMUTABLE}
ENV OBJECT_FLUENTD_HOST ${OBJECT_FLUENTD_HOST}
ENV OBJECT_FLUENTD_PORT ${OBJECT_FLUENTD_PORT}
ENV OBJECT_PROXY_HOSTNAME ${OBJECT_PROXY_HOSTNAME}
ENV OAUTH2_ACCESS_TOKEN_URI ${OAUTH2_ACCESS_TOKEN_URI}
ENV OAUTH2_PROTECTED_URIS ${OAUTH2_PROTECTED_URIS}
ENV OAUTH2_CLIENT_ID ${OAUTH2_CLIENT_ID}
ENV OAUTH2_CLIENT_SECRET ${OAUTH2_CLIENT_SECRET}
ENV SSL_VERIFYING_DISABLE ${SSL_VERIFYING_DISABLE}

COPY --from=builder /usr/src/app/target/fdns-ms-object-*.jar /app.jar

# pull latest
RUN apk update && apk upgrade --no-cache

# don't run as root user
RUN chown 1001:0 /app.jar
RUN chmod g+rwx /app.jar
USER 1001

ENTRYPOINT java -Dserver.tomcat.protocol-header=x-forwarded-proto -Dserver.tomcat.remote-ip-header=x-forwarded-for -jar /app.jar