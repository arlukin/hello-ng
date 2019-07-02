FROM gradle:jdk8 as builder
ENV GRADLE_OPTS "-Dorg.gradle.daemon=false"

COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN ./gradlew build


FROM openjdk:8-jre-alpine
EXPOSE 5000
COPY --from=builder /home/gradle/src/build/libs/hello-ng-1.0-SNAPSHOT-all.jar /app/hello-ng.jar
USER nobody
WORKDIR /app

ENV PORT 5000
CMD exec java -jar $SPS_JAVA_OPTS -server /app/hello-ng.jar
