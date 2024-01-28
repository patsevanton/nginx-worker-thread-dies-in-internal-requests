# Using the SHA256 hash for reproducibility,
# it is the fabiocicerchia/nginx-lua:1.21.6-alpine3.15.0 tag
FROM fabiocicerchia/nginx-lua@sha256:5ca81313baa0d3d90fda9a8c48e6adc9028f64beeee4c31618a071dbeaed05cc
RUN apk update && apk add alpine-sdk build-base cmake linux-headers libressl-dev pcre-dev zlib-dev \
      grpc-dev curl-dev protobuf-dev c-ares-dev re2-dev gdb

ENV OPENTELEMETRY_VERSION v1.2.0

RUN cd / && git clone --shallow-submodules --depth 1 --recurse-submodules -b ${OPENTELEMETRY_VERSION} \
  https://github.com/open-telemetry/opentelemetry-cpp.git
RUN cd / && git clone https://github.com/open-telemetry/opentelemetry-cpp-contrib.git \
  && cd /opentelemetry-cpp-contrib \
  && git checkout 3808bc3be386fbcc58d39cd858fb375d7e1fafa3

RUN cd /opentelemetry-cpp \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/install \
    -DCMAKE_PREFIX_PATH=/install \
    -DWITH_OTLP=ON \
    -DWITH_OTLP_GRPC=ON \
    -DWITH_OTLP_HTTP=OFF \
    -DBUILD_TESTING=OFF \
    -DWITH_EXAMPLES=OFF \
    -DWITH_ABSEIL=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    .. \
  && make -j2 \
  && make install

RUN cd /opentelemetry-cpp-contrib/instrumentation/nginx \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -DNGINX_BIN=/usr/sbin/nginx \
    -DCMAKE_PREFIX_PATH=/install \
    -DCMAKE_INSTALL_PREFIX=/etc/nginx/modules \
    -DCURL_LIBRARY=/usr/lib/libcurl.so.4 \
    -DNGINX_VERSION=1.21.6\
    .. \
  && make -j2 \
  && make install