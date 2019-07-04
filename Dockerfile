FROM openjdk:8-jre-alpine
USER nobody
WORKDIR /app
EXPOSE 5000
ENV PORT 5000
COPY build/libs/hello-ng-shadow.jar /app/hello-ng-shadow.jar
CMD exec java -jar $SPS_JAVA_OPTS -server /app/hello-ng-shadow.jar
