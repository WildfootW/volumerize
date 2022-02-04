FROM rclone/rclone:1.57.0 as rclone
FROM docker:20.10.12 as docker

FROM alpine:3.15.0
LABEL maintainer="Felix Haase <felix.haase@feki.de>"

ARG JOBBER_VERSION=1.4.4
ARG DUPLICITY_VERSION=0.8.21.post7

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
      azure-storage-blob \
      boto \
      boto3 \
      b2sdk \
      boxsdk[jwt] \
      dropbox \
      fasteners \
      gdata-python3 \
      google-api-python-client>=2.2.0 \
      google-auth-oauthlib \
      jottalib \
      mediafire \
      megatools \
      paramiko \
      pexpect \
      psutil \
      PyDrive \
      PyDrive2 \
      pyrax \
      python-swiftclient \
      python-keystoneclient \
      requests \
      requests_oauthlib \
      pycrypto \
      urllib3 \
      apprise \
      duplicity==${DUPLICITY_VERSION} && \
    mkdir -p /etc/volumerize /volumerize-cache /opt/volumerize /var/jobber/0 && \
    # Install Jobber
    wget --directory-prefix=/tmp https://github.com/dshearer/jobber/releases/download/v${JOBBER_VERSION}/jobber-${JOBBER_VERSION}-r0.apk && \
    apk add --allow-untrusted --no-scripts /tmp/jobber-${JOBBER_VERSION}-r0.apk && \
    # Cleanup
    apk del \
      curl \
      wget \
      python3-dev \
      alpine-sdk \
      linux-headers \
      gcc \
      musl-dev \
      librsync-dev && \
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
