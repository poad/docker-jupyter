ARG JDK_MAJOR_VERSION="17"
ARG ZULU_APT_KEY="0xB1998361219BD9C9"

ARG UBUNTU_CODENAME="focal"

ARG IJAVA_VERSION="1.3.0"

ARG NODE_VERSION="16.x"

FROM alpine:3 AS downloader

ARG NODE_VERSION
ARG IJAVA_VERSION

WORKDIR /tmp

ARG BUILD_DEPS="curl \
        gnupg \
        libssl1.1 \
        git \
        libffi-dev \
        openssl-dev \
        zlib \
        bash \
        m4 \
        rsync \
        alpine-sdk \
        diffutils \
        wget \
        xz"

RUN ARCH=$(apk --print-arch) \
 && apk --update add --no-cache --virtual .build-deps \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/* \
 && curl -sSLo /tmp/zulu-repo_all.deb https://cdn.azul.com/zulu/bin/zulu-repo_1.0.0-3_all.deb \
 && curl -sSLo "ijava-${IJAVA_VERSION}.zip" "https://github.com/SpencerPark/IJava/releases/download/v${IJAVA_VERSION}/ijava-${IJAVA_VERSION}.zip" \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && curl -sLo /tmp/setup_nodejs.sh "https://deb.nodesource.com/setup_${NODE_VERSION}" \
 && mkdir "ijava-${IJAVA_VERSION}" \
 && unzip "ijava-${IJAVA_VERSION}.zip" -d "ijava-${IJAVA_VERSION}"


FROM buildpack-deps:${UBUNTU_CODENAME}-curl

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG JDK_MAJOR_VERSION
ARG ZULU_APT_KEY


ARG USER_NAME="java"
ARG USER_HOME=/home/${USER_NAME}

ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8 "

USER root

WORKDIR /tmp

COPY --from=downloader /tmp/zulu-repo_all.deb /tmp/zulu-repo_all.deb
COPY --from=downloader /tmp/setup_nodejs.sh /tmp/setup_nodejs.sh
COPY --chown=1000:1000 requirements.txt /tmp/requirements.txt
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

ARG DEPENDENCIES="\
    autoconf \
    automake \
    bzip2 \
    dpkg-dev \
    erlang \
    file \
    gcc \
    git \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libevent-dev \
    libffi-dev \
    libgdbm-dev \
    libglib2.0-dev \
    libgmp-dev \
    libjpeg-dev \
    libkrb5-dev \
    liblzma-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libmaxminddb-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libpng-dev \
    libpq-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    libzmq3-dev \
    make \
    nodejs \
    patch \
    python3-dev \
    python3.10 \
    unzip \
    xz-utils \
    zlib1g-dev \
    tk-dev \
    uuid-dev"


ARG DEBIAN_FRONTEND=noninteractive

# extra dependencies (over what buildpack-deps already includes)
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${ZULU_APT_KEY}" \
 && apt-get install /tmp/zulu-repo_all.deb \
 && apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common "zulu${JDK_MAJOR_VERSION}-ca-jdk" \
 && add-apt-repository ppa:git-core/ppa -y \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && chmod +x /tmp/setup_nodejs.sh \
 && /tmp/setup_nodejs.sh \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN python3 /tmp/get-pip.py \
 && npm install -g yarn configurable-http-proxy \
 && pip3 install --no-cache-dir -U setuptools pip \
 && pip install --no-cache-dir -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && rm -f /tmp/requirements.txt /tmp/get-pip.py \
 && groupadd -g 1000 "${USER_NAME}" \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 "${USER_NAME}"

USER ${USER_NAME}

ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8 "

WORKDIR /tmp

RUN jupyter notebook --generate-config \
 && mkdir -p "${USER_HOME}/.jupyter" \
 && mkdir -p "${USER_HOME}/notebook" \
 && chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}"

COPY --chown=1000:1000 jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

WORKDIR ${USER_HOME}/notebook

EXPOSE 8888

CMD ["jupyter", "lab"]
