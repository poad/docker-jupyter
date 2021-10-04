ARG TEMP_JDK_DIR=/tmp/jdk
ARG IJAVA_VERSION="1.3.0"
ARG JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

FROM mcr.microsoft.com/java/jdk:17-zulu-alpine as downloader

ARG IJAVA_VERSION

ARG TEMP_JDK_DIR

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
 && ZULU_PATH=$(ls -d /usr/lib/jvm/zulu-*) \
 && mv "${ZULU_PATH}" "${TEMP_JDK_DIR}" \
 && curl -sSLo "ijava-${IJAVA_VERSION}.zip" "https://github.com/SpencerPark/IJava/releases/download/v${IJAVA_VERSION}/ijava-${IJAVA_VERSION}.zip" \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && mkdir "ijava-${IJAVA_VERSION}" \
 && unzip "ijava-${IJAVA_VERSION}.zip" -d "ijava-${IJAVA_VERSION}"

FROM alpine:3

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

ARG TEMP_JDK_DIR
ARG USER_NAME=jupyter
ARG USER_HOME=/home/${USER_NAME}
ARG IJAVA_VERSION
ARG JAVA_HOME

ENV LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH=/root/.local/bin:${PATH}:${JAVA_HOME}/bin

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

USER root

COPY --from=downloader ${TEMP_JDK_DIR} ${TEMP_JDK_DIR}


ARG BIN_DIR=/usr/bin
ARG MAN_DIR=/usr/share/man/man1

ARG BUILD_DEPS=" \
        alpine-sdk \
        bash \
        build-base \
        cargo \
        cmake \
        curl \
        czmq-dev \
        diffutils \
        freetype-dev \
        gnupg \
        git \
        libffi-dev \
        libpng-dev \
        libssl1.1 \
        libxml2-dev \
        libxslt-dev \
        libzmq \
        m4 \
        openssl-dev \
        python3 \
        python3-dev \
        py-setuptools \
        py3-pyzmq \
        rsync \
        rust \
        wget \
        xz \
        zlib"

WORKDIR /tmp

RUN JAVA_VERSION=$(cat "${TEMP_JDK_DIR}/release" | grep JAVA_VERSION= | cut -d "\"" -f2) \
 && mkdir -p /usr/lib/jvm/ \
 && cp -pR "${TEMP_JDK_DIR}" "/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64" \
 && ln -s "/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64" "${JAVA_HOME}" \
 && rm -rf "${TEMP_JDK_DIR}" \
 && apk --update add --no-cache --virtual ${BUILD_DEPS} \
 && rm -rf /var/cache/apk/* \
 && cd "${BIN_DIR}" \
 && find "${JAVA_HOME}/bin" -type f -perm -a=x -exec ln -s {} . \; \
 && mkdir -p ${MAN_DIR} \
 && cd "${MAN_DIR}" \
 && find "${JAVA_HOME}/man/man1" -type f -name "*.1" -exec ln -s {} . \; \
 && python3 /tmp/get-pip.py \
 && pip install --no-cache-dir -U setuptools \
 && rm -rf /tmp/get-pip.py \
 && addgroup -g 1000 -S ${USER_NAME} \
 && adduser -u 1000 -S  ${USER_NAME} -G ${USER_NAME}

USER ${USER_NAME}

ENV LANGUAGE=en_US:en \
    PATH=${USER_HOME}/.local/bin:${PATH}:${SBT_HOME}/bin:/${USER_HOME}/.cargo/bin:/usr/local/bin:${USER_HOME}/.mix/:${USER_HOME}/.ierl:${JAVA_HOME}/bin \
    JAVA_HOME=${JAVA_HOME}
COPY --chown=1000:1000 requirements.txt /tmp/requirements.txt
COPY --chown=1000:1000 --from=downloader /tmp/ijava-${IJAVA_VERSION} ${USER_HOME}/IJava

RUN pip install --no-cache-dir --user -U pip setuptools \
 && pip install --no-cache-dir --user -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root \
 && rm -f /tmp/requirements.txt \
 && mkdir -p ${USER_HOME}/IJava \
 && cd "${USER_HOME}/IJava/" \
 && python3 install.py --user \
 && rm -rf /tmp/requirements.txt \
 && mkdir -p "${USER_HOME}/notebooks"

COPY jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

HEALTHCHECK CMD [ "java", "-version" ]

WORKDIR ${USER_HOME}/notebooks

EXPOSE 8888

CMD ["jupyterhub", "--kernel=java"]
