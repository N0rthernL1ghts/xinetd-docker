FROM debian:stable-slim AS xinetd

# s6-overlay configuration
ENV S6_KEEP_ENV=1
ENV S6_KILL_GRACETIME=6000
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=1

# Build and some of image configuration
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}


ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
       apt install xinetd tcpd --yes  --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && tar xzf /tmp/s6overlay.tar.gz -C /

ADD rootfs /

# s6-overlay entrypoint
ENTRYPOINT ["/init"]