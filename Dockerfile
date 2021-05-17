FROM alpine AS download-extract
RUN apk update && apk add tar unzip curl && rm -rf /var/cache/*
WORKDIR /var/cache/
RUN curl -OL https://controlssoftware.sns.ornl.gov/css_phoebus/nightly/phoebus-linux.zip
RUN unzip phoebus-linux.zip


FROM openjdk:16-slim-buster as final
RUN apt-get update \
 && apt-get install -y --no-install-recommends --no-install-suggests \
    libopenjfx-jni \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY --from=download-extract /var/cache/phoebus-4.6.6/product-4.6.6.jar /phoebus/product.jar
COPY --from=download-extract /var/cache/phoebus-4.6.6/lib /phoebus/lib
WORKDIR /phoebus
ENTRYPOINT ["java", "-jar", "/phoebus/product.jar", "-server", "4918"]
