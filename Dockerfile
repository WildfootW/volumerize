FROM rclone/rclone:1.54.0 as rclone
FROM docker:20.10.5 as docker

FROM alpine:3.13.2
LABEL maintainer="Felix Haase <felix.haase@feki.de>"

ARG JOBBER_VERSION=1.4.4
ARG DUPLICITY_VERSION=0.8.18
ARG MEGATOOLS_VERSION=1.10.3

RUN apk upgrade --update && \
    apk add \
      bash \
      tzdata \
      tini \
      su-exec \
      gzip \
      gettext \
      tar \
      wget \
      curl \
      gmp-dev \
      tzdata \
      openssh \
      openssl \
      ca-certificates \
      python3-dev \
      gcc \
      glib \
      gnupg \
      alpine-sdk \
      linux-headers \
      musl-dev \
      rsync \
      lftp \
      py-cryptography \
      libffi-dev \
      librsync \
      librsync-dev \
      libcurl \
      py3-pip && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir wheel setuptools-scm && \
    pip3 install --no-cache-dir \
      fasteners \
      google-api-python-client>=2.2.0 \
      PyDrive \
      chardet \
      azure-storage-blob \
      boto \
      boto3 \
      paramiko \
      pexpect \
      pycrypto \
      python-keystoneclient \
      python-swiftclient \
      requests \
      requests_oauthlib \
      urllib3 \
      b2sdk \
      dropbox \
      apprise \
      duplicity==${DUPLICITY_VERSION} && \
    mkdir -p /etc/volumerize /volumerize-cache /opt/volumerize /var/jobber/0 && \
    # Install tools
    apk add \
      asciidoc \
      automake \
      autoconf \
      build-base \
      curl-dev \
      openssl-dev \
      glib-dev \
      libtool \
      make && \
    # Install Jobber
    wget --directory-prefix=/tmp https://github.com/dshearer/jobber/releases/download/v${JOBBER_VERSION}/jobber-${JOBBER_VERSION}-r0.apk && \
    apk add --allow-untrusted --no-scripts /tmp/jobber-${JOBBER_VERSION}-r0.apk && \
    # Install MEGAtools
    curl -fSL "https://megatools.megous.com/builds/megatools-${MEGATOOLS_VERSION}.tar.gz" -o /tmp/megatools.tgz && \
    tar -xzvf /tmp/megatools.tgz -C /tmp && \
    cd /tmp/megatools-${MEGATOOLS_VERSION} && \
    ./configure && \
    make && \
    make install && \
    # Cleanup
    apk del \
      asciidoc \
      automake \
      autoconf \
      build-base \
      curl \
      curl-dev \
      glib-dev \
      wget \
      python3-dev \
      openssl-dev \
      libtool \
      alpine-sdk \
      linux-headers \
      gcc \
      musl-dev \
      librsync-dev \
      make && \
    apk add \
        openssl && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/*

COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone
COPY --from=docker /usr/local/bin/ /usr/local/bin/

ENV VOLUMERIZE_HOME=/etc/volumerize \
    VOLUMERIZE_CACHE=/volumerize-cache \
    VOLUMERIZE_SCRIPT_DIR=/opt/volumerize \
    PATH=$PATH:/etc/volumerize \
    GOOGLE_DRIVE_SETTINGS=/credentials/cred.file \
    GOOGLE_DRIVE_CREDENTIAL_FILE=/credentials/googledrive.cred \
    GPG_TTY=/dev/console

USER root
WORKDIR /etc/volumerize
VOLUME ["/volumerize-cache"]
COPY imagescripts/ /opt/volumerize/
COPY scripts/ /etc/volumerize/
COPY postexecute/ /postexecute
ENTRYPOINT ["/sbin/tini","--","/opt/volumerize/docker-entrypoint.sh"]
CMD ["volumerize"]
