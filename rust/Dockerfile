ARG DISTRIBUTION="debian"
ARG DEBIAN_CODENAME="bullseye"
ARG UBUNTU_CODENAME="focal"

ARG LLVM_VERSION=15
ARG PYTHON_VERSION=3.11

FROM buildpack-deps:${DEBIAN_CODENAME}-curl AS downloader

RUN curl --proto '=https' --tlsv1.2 -sSfo /tmp/rust_setup.sh https://sh.rustup.rs

FROM python:${PYTHON_VERSION}-${DEBIAN_CODENAME}

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG DEBIAN_CODENAME
ARG UBUNTU_CODENAME

ARG LLVM_VERSION
ARG PYTHON_VERSION

ARG USER_NAME=jupyter
ARG USER_HOME=/home/${USER_NAME}

RUN groupadd -g 1000 ${USER_NAME}  \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 ${USER_NAME} 

COPY requirements.txt /tmp/requirements.txt
COPY --from=downloader --chown=${USER_NAME}:${USER_NAME} /tmp/rust_setup.sh /tmp/rust_setup.sh


ARG DEPENDENCIES="\
        autoconf \
        automake \
        bzip2 \
        dpkg-dev \
        file \
        gcc \
        git \
        clang-${LLVM_VERSION} \
        lld-${LLVM_VERSION} \
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
        unzip \
        xz-utils \
        zlib1g-dev \
        tk-dev \
        uuid-dev"

# extra dependencies (over what buildpack-deps already includes)
RUN rm -rf /var/lib/apt/lists/* \
 && apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A1715D88E1DF1F24 \
 && echo "deb http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && echo "deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ ${UBUNTU_CODENAME} main" >> /etc/apt/sources.list.d/git-core.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && pip3 install --no-cache-dir -U pip \
 && pip install --no-cache-dir -U setuptools \
 && pip install --no-cache-dir -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && jupyter notebook --generate-config --allow-root

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
 && evcxr_jupyter --install \
 && mkdir -p ${USER_HOME}/.jupyter

ADD jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

RUN mkdir -p ${USER_HOME}/notebook
WORKDIR ${USER_HOME}/notebook

HEALTHCHECK CMD [ "cargo", "--version" ]

EXPOSE 8888

CMD ["jupyter", "lab"]
