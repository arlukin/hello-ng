FROM openjdk:8-jre-alpine

USER nobody

COPY ./build/libs/hello-vertx-1.0-SNAPSHOT-all.jar /app/hello-vertx.jar
WORKDIR /app

ENV PORT 5000
EXPOSE $PORT
CMD exec java -jar $SPS_JAVA_OPTS -server /app/hello-vertx.jar
