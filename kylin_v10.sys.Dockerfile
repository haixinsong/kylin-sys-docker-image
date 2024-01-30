# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope

ARG TARGETARCH
FROM --platform=linux/${TARGETARCH} openeuler/openeuler:22.03-lts as bootstrap
# FROM --platform=linux/${TARGETARCH} kylin:v10-sp2-${TARGETARCH} as build

ARG TARGETARCH
ARG SP_VERSION
ARG TARGETVARIANT

RUN echo "I'm building kylin-V10SP${SP_VERSION} for arch ${TARGETARCH} ${TARGETVARIANT}"
RUN rm -rf /target && mkdir -p /target/etc/yum.repos.d && mkdir -p /etc/pki/rpm-gpg
COPY kylin-V10SP${SP_VERSION}.repo /target/etc/yum.repos.d/kylin_${TARGETVARIANT}.repo
COPY RPM-GPG-KEY-kylin /target/etc/pki/rpm-gpg/RPM-GPG-KEY-kylin
COPY RPM-GPG-KEY-kylin /etc/pki/rpm-gpg/RPM-GPG-KEY-kylin
RUN yum --installroot=/target \
    --releasever=10 \
    --setopt=tsflags=nodocs \
    install -y kylin-release coreutils rpm yum bash procps tar
RUN yum clean all --installroot /target && \
    rm -rf /target/var/cache/yum && \
    rm -rf /target/var/log/*

FROM --platform=linux/${TARGETARCH} scratch as runner
COPY --from=bootstrap /target /
RUN yum --releasever=10 \
    --setopt=tsflags=nodocs \
    install -y kylin-release coreutils rpm yum bash procps tar
RUN yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/log/*
RUN cp /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl && \
    build-locale-archive --install-langs="en:zh"

FROM --platform=linux/${TARGETARCH} scratch
COPY --from=runner / /
CMD /bin/bash

# SP1
# TARGETARCH=amd64 TARGETVARIANT=x86_64  SP_VERSION=1 && docker buildx build --progress=plain --no-cache . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log
# TARGETARCH=arm64 TARGETVARIANT=aarch64 SP_VERSION=1 && docker buildx build --progress=plain --no-cache . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log

# SP2 amd64 build command:
# TARGETARCH=amd64 TARGETVARIANT=x86_64 SP_VERSION=2 && docker buildx build --progress=plain . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log
# SP2 arm64 build command:
# TARGETARCH=arm64 TARGETVARIANT=aarch64 SP_VERSION=2 && docker buildx build --progress=plain . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log

# SP3 amd64 build command:
# TARGETARCH=amd64 TARGETVARIANT=x86_64 SP_VERSION=3 && docker buildx build --progress=plain --no-cache  . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log
# SP3 arm64 build command:
# TARGETARCH=arm64 TARGETVARIANT=aarch64 SP_VERSION=3 && docker buildx build --progress=plain . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log

# test
# TARGETARCH=amd64 TARGETVARIANT=x86_64 SP_VERSION=2 && docker buildx build --progress=plain . -f kylin_v10.sys.Dockerfile --platform=linux/$TARGETARCH -t kylin:v10-sp$SP_VERSION-$TARGETARCH-test --build-arg TARGETARCH=$TARGETARCH --build-arg TARGETVARIANT=$TARGETVARIANT --build-arg SP_VERSION=$SP_VERSION 2>&1 | tee kylin:v10-sp$SP_VERSION-$TARGETARCH-build.log
