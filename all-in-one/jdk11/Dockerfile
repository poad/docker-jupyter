ARG ALPINE_VERSION="3.12"
ARG ZULU_VERSION="11.41.23"
ARG JDK_VERSION="11.0.8"
ARG SHA256SUM="bd54bb1690ff7cd88f8b50aa089cd2e55911a62a18b096f43f0cf36fb0caec30"
ARG ZULU_ARCH="zulu${ZULU_VERSION}-ca-jdk${JDK_VERSION}-linux_musl_x64.tar.gz"
ARG JAVA_HOME="/usr/lib/jvm/zulu-11"
ARG JAVA_URL="https://cdn.azul.com/zulu/bin/${ZULU_ARCH}"

ARG SBT_VERSION="1.3.13"
ARG SCALA_VERSION="2.13.3"
ARG ALMOND_VERSION="0.10.5"
ARG IERL_VERSION="0.4.0"

ARG NODE_VERSION="lts"

FROM alpine:3 AS downloader

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
    git \
 && rm -rf /var/cache/apk/* \
 && INSTALL_DIR=$( dirname ${JAVA_HOME} ) \
 && ZULU_DIR=$( basename ${ZULU_ARCH} .tar.gz ) \
 && curl -sSLo ${ZULU_ARCH} ${JAVA_URL} \
 && mkdir -p ${INSTALL_DIR} \
 && echo "${SHA256SUM}  ${ZULU_ARCH}" | sha256sum -c - \
 && tar -xf ./${ZULU_ARCH} -C ${INSTALL_DIR} \
 && rm -f ${ZULU_ARCH} \
 && mv ${INSTALL_DIR}/${ZULU_DIR} ${JAVA_HOME} \
 && curl -sSL "https://sbt-downloads.cdnedge.bluemix.net/releases/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -sSLo /tmp/ierl https://github.com/filmor/ierl/releases/download/v${IERL_VERSION}/ierl \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py


FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

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
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

RUN apk --update add --no-cache --virtual .build-deps \
    binutils-gold \
    linux-headers \
    make \
    clang \
    clang-libs \
    clang-static \
    curl \
    libstdc++ \
    gnupg \
    libssl1.1 \
    python3 \
    python3-dev \
    erlang \
    elixir \
    nodejs \
    yarn \
    npm \
    libzmq \
    czmq-dev \
    py3-pyzmq \
    git \
    rust \
    rust-analysis \
    cargo \
    cargo-bash-completions \
    libffi-dev \
    openssl-dev \
    cmake \
    build-base \
    zlib \
    bash \
    m4 \
    rsync \
    freetype-dev \
    ca-certificates \
    libpng-dev \
    alpine-sdk \
    diffutils \
    libxml2-dev \
    libxslt-dev \
    unzip \
    xz \
 && rm -rf /var/cache/apk/* \
 && cd ${BIN_DIR} \
 && find ${JAVA_HOME}/bin -type f -perm -a=x -exec ln -s {} . \; \
 && mkdir -p ${MAN_DIR} \
 && cd ${MAN_DIR} \
 && find ${JAVA_HOME}/man/man1 -type f -name "*.1" -exec ln -s {} . \; \
 && python3 /tmp/get-pip.py \
 && npm install -g configurable-http-proxy \
 && pip install -U setuptools \
 && pip install -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && npm install -g --unsafe-perm itypescript \
 && its --install=global \
 && npm install -g --unsafe-perm ijavascript \
 && ijsinstall --install=global \
 && rm -f /tmp/requirements.txt \
 && cd /tmp \
 && chmod u+x ierl \
 && ./ierl install elixir \
 && ./ierl install lfe \
 && ./ierl install erlang \
 && rm -rf /tmp/get-pip.py


USER ${USER_NAME}

WORKDIR /tmp

RUN jupyter notebook --generate-config --allow-root \
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
