ARG ZULU_VERSION="11.35.15"
ARG JDK_VERSION="11.0.5"
ARG SHA256SUM="cef8591c619a4bec06a94d0f7e21847b04b97468a8385b6683b3c5fa2641ab57"
ARG ZULU_ARCH="zulu${ZULU_VERSION}-ca-jdk${JDK_VERSION}-linux_musl_x64.tar.gz"
ARG JAVA_HOME="/usr/lib/jvm/zulu-11"
ARG JAVA_URL="https://cdn.azul.com/zulu/bin/${ZULU_ARCH}"

ARG SBT_VERSION="1.3.6"
ARG SCALA_VERSION="2.13.1"
ARG ALMOND_VERSION="0.9.1"
ARG IERL_VERSION="0.4.0"
ARG EVCXR_VERSION="0.4.6"

FROM alpine:3 AS downloader

ARG SHA256SUM
ARG ZULU_ARCH
ARG JAVA_HOME
ARG JAVA_URL

ARG SBT_VERSION
ARG IERL_VERSION

ARG EVCXR_VERSION

RUN apk --update add --no-cache --virtual .build-deps \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/* \
 && INSTALL_DIR=$( dirname ${JAVA_HOME} ) \
 && ZULU_DIR=$( basename ${ZULU_ARCH} .tar.gz ) \
 && curl -Lso ${ZULU_ARCH} ${JAVA_URL} \
 && mkdir -p ${INSTALL_DIR} \
 && echo "${SHA256SUM}  ${ZULU_ARCH}" | sha256sum -c - \
 && tar -xf ./${ZULU_ARCH} -C ${INSTALL_DIR} \
 && rm -f ${ZULU_ARCH} \
 && mv ${INSTALL_DIR}/${ZULU_DIR} ${JAVA_HOME} \
 && curl -sL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && cd /tmp \
 && curl -sL "https://github.com/google/evcxr/archive/v${EVCXR_VERSION}.tar.gz" | tar -xz -C /tmp \
 && mv /tmp/evcxr-${EVCXR_VERSION} /tmp/evcxr \
 && wget https://github.com/filmor/ierl/releases/download/v${IERL_VERSION}/ierl


FROM alpine:3

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
ARG USER_NAME="jupyter"
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

RUN addgroup -g 1000 -S ${USER_NAME} \
 && adduser -u 1000 -S  ${USER_NAME} -G ${USER_NAME}

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

RUN apk --update add --no-cache --virtual .build-deps \
    binutils-gold \
    linux-headers \
    make \
    clang \
    clang-libs \
    clang-static \
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
    libpng-dev \
    alpine-sdk \
    diffutils \
    libxml2-dev \
    libxslt-dev \
    xz \
 && rm -rf /var/cache/apk/* \
 && cd ${BIN_DIR} \
 && find ${JAVA_HOME}/bin -type f -perm -a=x -exec ln -s {} . \; \
 && mkdir -p ${MAN_DIR} \
 && cd ${MAN_DIR} \
 && find ${JAVA_HOME}/man/man1 -type f -name "*.1" -exec ln -s {} . \; \
 && npm install -g configurable-http-proxy \
 && pip3 install -U setuptools \
 && pip3 install -U pip

COPY --chown=1000:1000 assets/tmp/requirements.txt /tmp/requirements.txt
COPY --chown=1000:1000 --from=downloader /tmp/evcxr /tmp/evcxr
COPY --chown=1000:1000 --from=downloader /tmp/ierl ${USER_HOME}/ierl 

USER ${USER_NAME}

RUN pip install --user -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root \
 && rm -f /tmp/requirements.txt \
 && cd /tmp \
 && git clone https://github.com/almond-sh/almond.git && \
    cd almond/project && \
    mv build.properties build.properties.bak && \
    sed -e "s/1\.3\.2/${SBT_VERSION}/g" build.properties.bak > build.properties && \
    rm -f build.properties.bak && \
    cd ../ && \
    bash scripts/coursier.sh bootstrap \
        -r jitpack \
        -i user -I user:sh.almond:scala-kernel-api_${SCALA_VERSION}:${ALMOND_VERSION} \
        sh.almond:scala-kernel_${SCALA_VERSION}:${ALMOND_VERSION} \
        -o almond && \
    ./almond --install \
 && cd /tmp \
 && cd evcxr/evcxr_jupyter \
 && cargo install evcxr_jupyter \
 && evcxr_jupyter --install  \
 && cd /tmp \
 && git clone https://github.com/ligee/kotlin-jupyter.git \
 && cd /tmp/kotlin-jupyter \
 && mv build.gradle build.gradle.bak \
 && sed -e "s/'1\.2\.21'/'1.3.61'/g" build.gradle.bak > build.gradle \
 && mv gradle/wrapper/gradle-wrapper.properties gradle/wrapper/gradle-wrapper.properties.bak \
 && sed -e "s/5\.6\.2/6.0.1/g" gradle/wrapper/gradle-wrapper.properties.bak > gradle/wrapper/gradle-wrapper.properties \
 && ./gradlew install \
 && cd ${USER_HOME} \
 && chmod u+x ierl \
 && ./ierl install elixir --user \
 && ./ierl install lfe --user \
 && ./ierl install erlang --user \
 && mkdir -p ${USER_HOME}/.jupyter \
 && mkdir -p ${USER_HOME}/notebook \
 && chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME} \
 && rm -rf /tmp/*

COPY --chown=1000:1000 assets/root/.jupyter/jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

WORKDIR ${USER_HOME}/notebook

EXPOSE 8888

CMD ["jupyter", "lab"]
