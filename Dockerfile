# -------------------------------------
FROM debian:stable-slim as download-and-extract
ARG GIT_COMMIT=master
RUN apt-get update && apt-get install -y wget
RUN wget https://github.com/ControlSystemStudio/phoebus/archive/$GIT_COMMIT.tar.gz
RUN tar -xf $GIT_COMMIT.tar.gz
RUN mv /phoebus-$GIT_COMMIT* /phoebus-src

# -------------------------------------
FROM openjdk:11-buster as builder
RUN apt-get update && apt-get install -y maven openjfx libopenjfx-jni libopenjfx-java
COPY --from=download-and-extract /phoebus-src /phoebus-src
WORKDIR /phoebus-src
RUN mvn clean verify -f dependencies/pom.xml
RUN mvn -DskipTests clean install

# -------------------------------------
FROM openjdk:11-buster as final
ARG GIT_COMMIT=master
LABEL git_commit=$GIT_COMMIT
RUN apt-get update && apt-get install -y openjfx libopenjfx-jni libopenjfx-java
COPY --from=builder /phoebus-src/phoebus-product/target /phoebus
WORKDIR /phoebus
RUN ln -s product-4.6.6-SNAPSHOT.jar product.jar
# assert that all dependencies can be resolved:
RUN jdeps --class-path './lib/*' --recursive product.jar | (! grep 'not found')
ENTRYPOINT ["java", "-jar", "/phoebus/product.jar", "-server", "4918"]
