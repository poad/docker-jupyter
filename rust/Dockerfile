FROM alpine:3 AS downloader

RUN apk --update add --no-cache \
        curl \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && curl --proto '=https' --tlsv1.2 -sSfo /tmp/rust_setup.sh https://sh.rustup.rs

FROM buildpack-deps:focal-curl

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG USER_NAME=jupyter
ARG USER_HOME=/home/${USER_NAME}

RUN groupadd -g 1000 ${USER_NAME}  \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 ${USER_NAME} 

COPY requirements.txt /tmp/requirements.txt
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader --chown=${USER_NAME}:${USER_NAME} /tmp/rust_setup.sh /tmp/rust_setup.sh


ARG DEPENDENCIES="\
        autoconf \
        automake \
        bzip2 \
        dpkg-dev \
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
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && python3 /tmp/get-pip.py \
 && pip install -U setuptools \
 && pip install -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root \
 && rm -rf /tmp/get-pip.py

# Install Rust kernel
USER ${USER_NAME}

WORKDIR ${USER_HOME}
ENV PATH ${PATH}:${USER_HOME}/.cargo/bin
RUN chmod +x /tmp/rust_setup.sh \
 && /tmp/rust_setup.sh -y \
 && rm -rf  /tmp/rust_setup.sh \
 && jupyter serverextension enable --py jupyterlab \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root \
 && cargo install evcxr_jupyter --no-default-features \
 && evcxr_jupyter --install

RUN mkdir -p ${USER_HOME}/.jupyter

ADD jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

RUN mkdir -p ${USER_HOME}/notebook
WORKDIR ${USER_HOME}/notebook

HEALTHCHECK CMD [ "cargo", "--version" ]

EXPOSE 8888

CMD ["jupyter", "lab"]
