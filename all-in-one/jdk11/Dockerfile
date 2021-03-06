ARG UBUNTU_CODENAME="focal"
ARG ZULU_VERSION="11.43.55"
ARG JDK_VERSION="11.0.9.1"
ARG SHA256SUM="6c79bfe8bb06c82b72ef2f293a14becef56b3078d298dc75fda4225cbb2d3d0c"
ARG ZULU_ARCH="zulu${ZULU_VERSION}-ca-jdk${JDK_VERSION}-linux_x64.tar.gz"
ARG JAVA_HOME="/usr/lib/jvm/zulu-11"
ARG JAVA_URL="https://cdn.azul.com/zulu/bin/${ZULU_ARCH}"

ARG SBT_VERSION="1.4.3"
ARG SCALA_VERSION="2.13.3"
ARG ALMOND_VERSION="0.10.9"
ARG IERL_VERSION="0.4.0"

ARG NODE_VERSION="14.x"

FROM alpine:3 AS downloader

ARG NODE_VERSION
ARG SHA256SUM
ARG ZULU_ARCH
ARG JAVA_HOME
ARG JAVA_URL

ARG SBT_VERSION
ARG IERL_VERSION

RUN apk --update add --no-cache --virtual .build-deps \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/* \
 && INSTALL_DIR=$( dirname ${JAVA_HOME} ) \
 && ZULU_DIR=$( basename ${ZULU_ARCH} .tar.gz ) \
 && curl -sSLo ${ZULU_ARCH} ${JAVA_URL} \
 && mkdir -p ${INSTALL_DIR} \
 && echo "${SHA256SUM}  ${ZULU_ARCH}" | sha256sum -c - \
 && tar -xf ./${ZULU_ARCH} -C ${INSTALL_DIR} \
 && rm -f ${ZULU_ARCH} \
 && mv ${INSTALL_DIR}/${ZULU_DIR} ${JAVA_HOME} \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -sSLo /tmp/ierl https://github.com/filmor/ierl/releases/download/v${IERL_VERSION}/ierl \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && curl --proto '=https' --tlsv1.2 -sSfo /tmp/rust_setup.sh https://sh.rustup.rs \
 && curl -sLo /tmp/setup_nodejs.sh https://deb.nodesource.com/setup_${NODE_VERSION} \
 && curl -sSLo /tmp/erlang-solutions_2.0_all.deb https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb



FROM buildpack-deps:${UBUNTU_CODENAME}-curl

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG ZULU_VERSION
ARG JDK_VERSION
ARG SHA256SUM
ARG ZULU_ARCH
ARG JAVA_HOME

ARG SBT_VERSION
ARG SCALA_VERSION
ARG ALMOND_VERSION
ARG IERL_VERSION

ARG USER_NAME="node"
ARG USER_HOME=/home/${USER_NAME}

RUN groupadd -g 1000 ${USER_NAME}  \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 ${USER_NAME}


RUN echo "SBT_VERSION: ${SBT_VERSION}" \
 && echo "SCALA_VERSION: ${SCALA_VERSION}" \
 && echo "ALMOND_VERSION: ${ALMOND_VERSION}" \
 && echo "IERL_VERSION: ${IERL_VERSION}" \
 && echo "ZULU_VERSION: ${ZULU_VERSION}" \
 && echo "JDK_VERSION: ${JDK_VERSION}" \
 && echo "ZULU_ARCH: ${ZULU_ARCH}"

ENV SBT_HOME=/usr/local/sbt \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=${JAVA_HOME} \
    CC=/usr/bin/clang \
    CXX=/usr/bin/clang++ \
    PATH=${PATH}:${SBT_HOME}/bin:/root/.cargo/bin:/usr/local/bin:${USER_HOME}/.mix/:${USER_HOME}/.ierl:${JAVA_HOME}/bin

USER ${USER_NAME}

ENV SBT_HOME=/usr/local/sbt \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/zulu-11 \
    CC=/usr/bin/clang \
    CXX=/usr/bin/clang++ \
    PATH=${USER_HOME}/.local/bin:${PATH}:${SBT_HOME}/bin:/${USER_HOME}/.cargo/bin:/usr/local/bin:¥${USER_HOME}/.mix/:${USER_HOME}/.ierl:${JAVA_HOME}/bin

USER root

WORKDIR /tmp

ARG BIN_DIR=/usr/bin
ARG MAN_DIR=/usr/share/man/man1

COPY --from=downloader ${JAVA_HOME} ${JAVA_HOME}
COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 assets/tmp/requirements.txt /tmp/requirements.txt
COPY --chown=1000:1000 --from=downloader /tmp/ierl /tmp/ierl 
COPY --chown=1000:1000 --from=downloader /tmp/rust_setup.sh /tmp/rust_setup.sh
COPY --from=downloader /tmp/setup_nodejs.sh /tmp/setup_nodejs.sh
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader /tmp/erlang-solutions_2.0_all.deb /tmp/erlang-solutions_2.0_all.deb

ARG DEPENDENCIES="\
        autoconf \
        automake \
        bzip2 \
        dpkg-dev \
        erlang \
        file \
        gcc \
        git \
        clang-11 \
        lld-11 \
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
        python3.9 \
        unzip \
        xz-utils \
        zlib1g-dev \
        tk-dev \
        uuid-dev"

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 && echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && add-apt-repository ppa:git-core/ppa -y \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && chmod +x /tmp/setup_nodejs.sh \
 && /tmp/setup_nodejs.sh \
 && dpkg -i /tmp/erlang-solutions_2.0_all.deb \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && cd ${BIN_DIR} \
 && find ${JAVA_HOME}/bin -type f -perm -a=x -exec ln -s {} . \; \
 && mkdir -p ${MAN_DIR} \
 && cd ${MAN_DIR} \
 && find ${JAVA_HOME}/man/man1 -type f -name "*.1" -exec ln -s {} . \; \
 && python3 /tmp/get-pip.py \
 && npm install -g yarn configurable-http-proxy \
 && pip3 install -U setuptools pip \
 && pip install -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && rm -f /tmp/requirements.txt /tmp/get-pip.py \
 && cd /tmp \
 && chmod u+x ierl \
 && ./ierl install elixir \
 && ./ierl install lfe \
 && ./ierl install erlang

RUN ln -s /usr/bin/clang-11 /usr/bin/clang

USER ${USER_NAME}

WORKDIR /tmp

RUN jupyter notebook --generate-config --allow-root \
 && chmod +x /tmp/rust_setup.sh \
 && /tmp/rust_setup.sh -y \
 && git clone https://github.com/almond-sh/almond.git && \
    cd almond/project && \
    mv build.properties build.properties.bak && \
    sed -e "s/1\.3\.3/${SBT_VERSION}/g" build.properties.bak > build.properties && \
    rm -f build.properties.bak && \
    cd ../ && \
    bash scripts/coursier.sh bootstrap \
        -r jitpack \
        -i user -I user:sh.almond:scala-kernel-api_${SCALA_VERSION}:${ALMOND_VERSION} \
        sh.almond:scala-kernel_${SCALA_VERSION}:${ALMOND_VERSION} \
        -o almond && \
    ./almond --install

RUN cargo install evcxr_jupyter --no-default-features \
 && evcxr_jupyter --install

USER root
RUN rm -rf /tmp/*

USER ${USER_NAME}

RUN mkdir -p ${USER_HOME}/.jupyter \
 && mkdir -p ${USER_HOME}/notebook \
 && chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}

COPY --chown=1000:1000 assets/root/.jupyter/jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

WORKDIR ${USER_HOME}/notebook

EXPOSE 8888

CMD ["jupyter", "lab"]
