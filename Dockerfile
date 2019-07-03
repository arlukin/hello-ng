FROM openjdk:8-jre-alpine
EXPOSE 5000
COPY build/libs/hello-ng-shadow.jar /app/hello-ng-shadow.jar
USER nobody
WORKDIR /app

ENV PORT 5000
CMD exec java -jar $SPS_JAVA_OPTS -server /app/hello-ng-shadow.jar
