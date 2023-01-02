ARG DISTRIBUTION="debian"
ARG DEBIAN_CODENAME="bullseye"
ARG UBUNTU_CODENAME="focal"

ARG JDK_MAJOR_VERSION="17"
ARG IJAVA_VERSION="1.3.0"
ARG NODE_VERSION="18.x"
ARG PYTHON_VERSION=3.11
ARG LLVM_VERSION=15

FROM buildpack-deps:${DEBIAN_CODENAME}-curl AS downloader

ARG NODE_VERSION
ARG IJAVA_VERSION

WORKDIR /tmp

RUN apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install -qqy --no-install-recommends unzip \
 && curl -sSLo /tmp/bellsoft.key https://download.bell-sw.com/pki/GPG-KEY-bellsoft \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -sSLo "ijava-${IJAVA_VERSION}.zip" "https://github.com/SpencerPark/IJava/releases/download/v${IJAVA_VERSION}/ijava-${IJAVA_VERSION}.zip" \
 && curl -sLo /tmp/setup_nodejs.sh "https://deb.nodesource.com/setup_${NODE_VERSION}" \
 && mkdir "ijava-${IJAVA_VERSION}" \
 && unzip "ijava-${IJAVA_VERSION}.zip" -d "ijava-${IJAVA_VERSION}"


FROM python:${PYTHON_VERSION}-${DEBIAN_CODENAME}

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG DEBIAN_CODENAME
ARG UBUNTU_CODENAME

ARG JDK_MAJOR_VERSION
ARG PYTHON_VERSION
ARG LLVM_VERSION

ARG USER_NAME="java"
ARG USER_HOME=/home/${USER_NAME}

ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8 "

USER root

WORKDIR /tmp

COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader /tmp/bellsoft.key /tmp/bellsoft.key
COPY --from=downloader /tmp/setup_nodejs.sh /tmp/setup_nodejs.sh
COPY --chown=1000:1000 requirements.txt /tmp/requirements.txt

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
    unzip \
    xz-utils \
    zlib1g-dev \
    tk-dev \
    uuid-dev"


ARG DEBIAN_FRONTEND=noninteractive

# extra dependencies (over what buildpack-deps already includes)
RUN rm -rf /var/lib/apt/lists/* \
 && apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && cat /tmp/bellsoft.key | apt-key add - \
 && rm -rf /tmp/bellsoft.key \
 && echo "deb [arch=$(dpkg --print-architecture)] https://apt.bell-sw.com/ stable main" > /etc/apt/sources.list.d/bell-sw.list \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A1715D88E1DF1F24 \
 && echo "deb http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && echo "deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ ${UBUNTU_CODENAME} main" >> /etc/apt/sources.list.d/git-core.list \
 && chmod +x /tmp/setup_nodejs.sh \
 && /tmp/setup_nodejs.sh \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends "bellsoft-java${JDK_MAJOR_VERSION}-full" ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/llvm-snapshot.gpg.key /tmp/setup_nodejs.sh

RUN npm install -g npm \
 && npm install -g yarn configurable-http-proxy \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && pip3 install --no-cache-dir -U pip \
 && pip install --no-cache-dir -U setuptools \
 && pip install --no-cache-dir -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && rm -f /tmp/requirements.txt \
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
