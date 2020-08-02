ARG ZULU_VERSION="11.41.23"
ARG JDK_VERSION="11.0.8"
ARG SHA256SUM="bd54bb1690ff7cd88f8b50aa089cd2e55911a62a18b096f43f0cf36fb0caec30"
ARG ZULU_ARCH="zulu${ZULU_VERSION}-ca-jdk${JDK_VERSION}-linux_musl_x64.tar.gz"
ARG JAVA_HOME="/usr/lib/jvm/zulu-11"
ARG IJAVA_VERSION="1.3.0"

FROM alpine:latest as downloader

ARG ZULU_VERSION
ARG JAVA_VERSION
ARG SHA256SUM
ARG ZULU_ARCH
ARG IJAVA_VERSION
ARG JAVA_URL="https://cdn.azul.com/zulu/bin/${ZULU_ARCH}"

ARG JAVA_HOME

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

RUN apk --update add --no-cache --virtual .build-deps \
    ${BUILD_DEPS} \
 && rm -rf /var/cache/apk/* \
 && INSTALL_DIR=$( dirname ${JAVA_HOME} ) \
 && ZULU_DIR=$( basename ${ZULU_ARCH} .tar.gz ) \
 && curl -Lso ${ZULU_ARCH} ${JAVA_URL} \
 && mkdir -p ${INSTALL_DIR} \
 && echo "${JAVA_URL}" \
 && echo "${SHA256SUM}  ${ZULU_ARCH}" | sha256sum -c - \
 && tar -xf ./${ZULU_ARCH} -C ${INSTALL_DIR} \
 && rm -f ${ZULU_ARCH} \
 && mv ${INSTALL_DIR}/${ZULU_DIR} ${JAVA_HOME} \
 && wget https://github.com/SpencerPark/IJava/releases/download/v${IJAVA_VERSION}/ijava-${IJAVA_VERSION}.zip \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && mkdir ijava-${IJAVA_VERSION} \
 && unzip ijava-${IJAVA_VERSION}.zip -d ijava-${IJAVA_VERSION}

FROM alpine:3

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

ARG JAVA_HOME
ARG USER_NAME=jupyter
ARG USER_HOME=/home/${USER_NAME}
ARG IJAVA_VERSION

ENV LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=${JAVA_HOME} \
    PATH=/root/.local/bin:${PATH}:${JAVA_HOME}/bin

RUN addgroup -g 1000 -S ${USER_NAME} \
 && adduser -u 1000 -S  ${USER_NAME} -G ${USER_NAME}

USER ${USER_NAME}

ENV LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=${JAVA_HOME} \
    PATH=${USER_HOME}/.local/bin:${PATH}:${SBT_HOME}/bin:/${USER_HOME}/.cargo/bin:/usr/local/bin:¥${USER_HOME}/.mix/:${USER_HOME}/.ierl:${JAVA_HOME}/bin

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

USER root

WORKDIR /tmp

ARG BIN_DIR=/usr/bin
ARG MAN_DIR=/usr/share/man/man1

ARG BUILD_DEPS="curl \
        gnupg \
        libssl1.1 \
        python3 \
        python3-dev \
        py-setuptools \
        libzmq \
        czmq-dev \
        py3-pyzmq \
        git \
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
        wget \
        xz"

COPY --from=downloader ${JAVA_HOME} ${JAVA_HOME}
COPY --chown=1000:1000 requirements.txt /tmp/requirements.txt

RUN apk --update add --no-cache --virtual ${BUILD_DEPS} \
 && rm -rf /var/cache/apk/* \
 && cd ${BIN_DIR} \
 && find ${JAVA_HOME}/bin -type f -perm -a=x -exec ln -s {} . \; \
 && mkdir -p ${MAN_DIR} \
 && cd ${MAN_DIR} \
 && find ${JAVA_HOME}/man/man1 -type f -name "*.1" -exec ln -s {} . \; \
 && python3 /tmp/get-pip.py \
 && pip install -U setuptools \
 && rm -rf /tmp/get-pip.py

USER ${USER_NAME}

COPY --chown=1000:1000 --from=downloader /tmp/ijava-${IJAVA_VERSION} ${USER_HOME}/IJava

RUN pip install --user -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root \
 && rm -f /tmp/requirements.txt \
 && mkdir -p ${USER_HOME}/IJava \
 && cd ${USER_HOME}/IJava/ \
 && python3 install.py --user \
 && rm -rf /tmp/requirements.txt \
 && mkdir -p ${USER_HOME}/notebooks

COPY jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

HEALTHCHECK CMD [ "java", "-version" ]

WORKDIR ${USER_HOME}/notebooks

EXPOSE 8888

CMD ["jupyterhub", "--kernel=java"]
