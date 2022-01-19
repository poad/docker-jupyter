ARG JDK_MAJOR_VERSION="8"

ARG UBUNTU_CODENAME="focal"

ARG SBT_VERSION="1.6.1"
ARG SCALA_VERSION="2.13.4"
# ARG SCALA2_LATEST_VERSION="2.13.7"
# ARG SCALA3_VERSION="3.0.4"
ARG ALMOND_VERSION="0.11.2"
ARG IERL_VERSION="0.4.0"

ARG PYTHON_VERSION=3.10

ARG LLVM_VERSION=13
ARG NODE_VERSION="16.x"

FROM alpine:3 AS downloader

ARG NODE_VERSION

ARG SBT_VERSION
ARG IERL_VERSION

RUN ARCH=$(apk --print-arch) \
 && apk --update add --no-cache --virtual .build-deps \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/* \
 && curl -sSLo /tmp/corretto.key https://apt.corretto.aws/corretto.key \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -sSLo /tmp/ierl "https://github.com/filmor/ierl/releases/download/v${IERL_VERSION}/ierl" \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && curl --proto '=https' --tlsv1.2 -sSfo /tmp/rust_setup.sh https://sh.rustup.rs \
 && curl -sLo /tmp/setup_nodejs.sh "https://deb.nodesource.com/setup_${NODE_VERSION}" \
 && curl -sSLo /tmp/erlang-solutions_all.deb https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
 && curl -fLo /tmp/coursier https://github.com/coursier/launchers/raw/master/cs-${ARCH}-pc-linux


FROM buildpack-deps:${UBUNTU_CODENAME}-curl

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG JDK_MAJOR_VERSION

ARG SBT_VERSION
ARG SCALA_VERSION
# ARG SCALA2_LATEST_VERSION
# ARG SCALA3_VERSION
ARG ALMOND_VERSION
ARG IERL_VERSION

ARG LLVM_VERSION
ARG PYTHON_VERSION

ARG USER_NAME="node"
ARG USER_HOME=/home/${USER_NAME}

ENV SBT_HOME="/usr/local/sbt"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV CC="/usr/bin/clang-${LLVM_VERSION}"
ENV CXX="/usr/bin/clang++-${LLVM_VERSION}"

USER root

WORKDIR /tmp

COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader /tmp/corretto.key /tmp/corretto.key
COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 assets/tmp/requirements.txt /tmp/requirements.txt
COPY --chown=1000:1000 --from=downloader /tmp/ierl /tmp/ierl 
COPY --chown=1000:1000 --from=downloader /tmp/rust_setup.sh /tmp/rust_setup.sh
COPY --from=downloader /tmp/setup_nodejs.sh /tmp/setup_nodejs.sh
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader /tmp/erlang-solutions_all.deb /tmp/erlang-solutions_all.deb

ARG DEPENDENCIES="\
        autoconf \
        automake \
        bzip2 \
        dpkg-dev \
        erlang \
        file \
        gcc \
        git \
        clang-${LLVM_VERSION} \
        clang++-${LLVM_VERSION} \
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
        nodejs \
        patch \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        libpython${PYTHON_VERSION}-dev \
        unzip \
        xz-utils \
        zlib1g-dev \
        tk-dev \
        uuid-dev"

COPY --chown=1000:1000 --from=downloader /tmp/coursier /usr/local/bin/cs

RUN chmod +x /usr/local/bin/cs

ARG DEBIAN_FRONTEND=noninteractive

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && cat /tmp/corretto.key | apt-key add - \
 && rm -rf /tmp/corretto.key \
 && echo "deb https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/aws-corretto.list \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 && echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && add-apt-repository ppa:git-core/ppa -y \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && chmod +x /tmp/setup_nodejs.sh \
 && /tmp/setup_nodejs.sh \
 && dpkg -i /tmp/erlang-solutions_all.deb \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends "java-1.${JDK_MAJOR_VERSION}.0-amazon-corretto-jdk" ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/llvm-snapshot.gpg.key /tmp/setup_nodejs.sh

RUN npm install -g npm \
 && npm install -g yarn configurable-http-proxy \
 && update-alternatives --install "/usr/bin/python3" "python3" "/usr/bin/python${PYTHON_VERSION}" 31000 \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && python /tmp/get-pip.py --no-cache-dir \
 && pip3 install --no-cache-dir -U setuptools pip \
 && pip install --no-cache-dir -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && npm -g i --unsafe-perm ijavascript \
 && ijsinstall --install=global \
 && rm -f /tmp/requirements.txt /tmp/get-pip.py \
 && cd /tmp \
 && chmod u+x ierl \
 && ./ierl install elixir \
 && ./ierl install lfe \
 && ./ierl install erlang \
 && ln -s "/usr/bin/clang-${LLVM_VERSION}" /usr/bin/clang \
 && groupadd -g 1000 "${USER_NAME}" \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 "${USER_NAME}" \
 && cs bootstrap \
      -r jitpack \
      -i user -I "user:sh.almond:scala-kernel-api_${SCALA_VERSION}:${ALMOND_VERSION}" \
      "sh.almond:scala-kernel_${SCALA_VERSION}:${ALMOND_VERSION}" \
      -M almond.ScalaKernel \
      --default=true --sources \
 && cs launch --fork "almond:${ALMOND_VERSION}" -M almond.ScalaKernel --scala "${SCALA_VERSION}" -- --install --id scala$(echo "${SCALA_VERSION}" | cut -f1-2 -d. | sed "s/\.//") --display-name "Scala ($(echo ${SCALA_VERSION} | cut -f1-2 -d.))"
# RUN cs launch --fork "almond:${ALMOND_VERSION}" -M almond.ScalaKernel --scala "${SCALA2_LATEST_VERSION}" -- --install --id "scala2-latest" --display-name "Scala (2.x latest)" \
# RUN cs launch --fork "almond:${ALMOND_VERSION}" -M almond.ScalaKernel --scala "${SCALA3_VERSION}" -- --install --id scala$(echo "${SCALA3_VERSION}" | cut -f1-2 -d. | sed "s/\.//") --display-name "Scala ($(echo ${SCALA3_VERSION} | cut -f1-2 -d.))" \

USER ${USER_NAME}

ENV SBT_HOME="/usr/local/sbt"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8 "
ENV CC="/usr/bin/clang"
ENV CXX="/usr/bin/clang++"
ENV PATH="${PATH}:${SBT_HOME}/bin:/${USER_HOME}/.cargo/bin:/usr/local/bin:${USER_HOME}/.mix/:${USER_HOME}/.ierl"

WORKDIR /tmp

RUN jupyter notebook --generate-config \
 && chmod +x /tmp/rust_setup.sh \
 && /tmp/rust_setup.sh -y \
 && cargo install evcxr_jupyter --no-default-features \
 && evcxr_jupyter --install \
 && mkdir -p "${USER_HOME}/.jupyter" \
 && mkdir -p "${USER_HOME}/notebook" \
 && chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}"

COPY --chown=1000:1000 assets/root/.jupyter/jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

WORKDIR ${USER_HOME}/notebook

EXPOSE 8888

CMD ["jupyter", "lab"]
