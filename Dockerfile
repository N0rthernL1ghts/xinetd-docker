ARG ALPINE_VERSION="3.15"
FROM alpine:${ALPINE_VERSION} AS builder

ARG XINETD_VERSION="2.3.15.4"
ARG XINETD_RELEASE_DL="https://github.com/openSUSE/xinetd/releases/download/${XINETD_VERSION}/xinetd-${XINETD_VERSION}.tar.xz"
WORKDIR "/tmp/xinetd/src"

RUN mkdir /build -p \
    && wget -O ../xinetd.tar.xz "${XINETD_RELEASE_DL}" \
    && cd ../ && tar xf xinetd.tar.xz  --strip 1 --directory src \
    && cd src \
    && apk add --update --no-cache alpine-sdk autoconf automake \
    && aclocal \
    && automake \
    && ./configure --prefix /build \
    && make \
    && make install \
    && rm /build/share -rf \
    && rm /build/etc/xinetd.d/*



FROM scratch AS rootfs

COPY --from=builder ["/build", "/"]
COPY ["./rootfs", "/"]



ARG ALPINE_VERSION
FROM nlss/base-alpine:${ALPINE_VERSION} AS xinetd

COPY --from=rootfs ["/", "/"]

# s6-overlay configuration
ENV S6_KILL_GRACETIME=6000
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=1