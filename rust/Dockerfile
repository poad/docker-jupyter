FROM alpine:3

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG EVCXR_VERSION
ARG USER_NAME=jupyter
ARG USER_HOME=/home/${USER_NAME}

RUN addgroup -g 1000 -S ${USER_NAME} \
 && adduser -u 1000 -S  ${USER_NAME} -G ${USER_NAME}

COPY requirements.txt /tmp/requirements.txt

RUN apk --update add --no-cache --virtual  \
        curl \
        gnupg \
        libssl1.1 \
        python3 \
        python3-dev \
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
        libxml2-dev \
        libxslt-dev \
        cmake \
        build-base \
        zlib \
        bash \
        m4 \
        rsync \
        freetype-dev \
        libpng-dev \
        ca-certificates \
        unzip \
 && rm -rf /var/cache/apk/* \
 && pip3 install -U setuptools pip \
 && pip install -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root

# Install Rust kernel
USER ${USER_NAME}

WORKDIR ${USER_HOME}
ENV PATH ${PATH}:${USER_HOME}/.cargo/bin
RUN  jupyter serverextension enable --py jupyterlab \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root \
 && cargo install evcxr_jupyter \
 && evcxr_jupyter --install

RUN mkdir -p ${USER_HOME}/.jupyter

ADD jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

RUN mkdir -p ${USER_HOME}/notebook
WORKDIR ${USER_HOME}/notebook

HEALTHCHECK CMD [ "cargo", "--version" ]

EXPOSE 8888

CMD ["jupyter", "lab"]
