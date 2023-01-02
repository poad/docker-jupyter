ARG JDK_MAJOR_VERSION="17"

ARG DISTRIBUTION="debian"
ARG DEBIAN_CODENAME="bullseye"
ARG UBUNTU_CODENAME="focal"

ARG SBT_VERSION="1.8.0"
ARG SCALA_VERSION="2.13.10"
ARG SCALA3_VERSION="3.1.3"
ARG ALMOND_VERSION="0.13.2"
ARG IERL_VERSION="0.6.0"

ARG PYTHON_VERSION=3.11

ARG LLVM_VERSION=15
ARG NODE_VERSION="18.x"

FROM buildpack-deps:${DEBIAN_CODENAME}-curl AS downloader

ARG NODE_VERSION

ARG SBT_VERSION
ARG IERL_VERSION

RUN apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install -qqy --no-install-recommends unzip \
 && ARCH=$(dpkg --print-architecture) \
 && if [ "${ARCH}" = "arm64" ]; then ARCH="aarch64"; fi \
 && curl -sSLo /tmp/bellsoft.key https://download.bell-sw.com/pki/GPG-KEY-bellsoft \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -sSLo /tmp/ierl "https://github.com/filmor/ierl/releases/download/v${IERL_VERSION}/ierl" \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl --proto '=https' --tlsv1.2 -sSfo /tmp/rust_setup.sh https://sh.rustup.rs \
 && curl -sLo /tmp/setup_nodejs.sh "https://deb.nodesource.com/setup_${NODE_VERSION}" \
 && curl -sSLo /tmp/erlang-solutions_all.deb https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb \
 && curl -fsSLo /tmp/coursier https://github.com/coursier/launchers/raw/master/cs-${ARCH}-pc-linux


FROM python:${PYTHON_VERSION}-${DEBIAN_CODENAME}

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG DEBIAN_CODENAME
ARG UBUNTU_CODENAME

ARG JDK_MAJOR_VERSION

ARG SBT_VERSION
ARG SCALA_VERSION
# ARG SCALA2_LATEST_VERSION
ARG SCALA3_VERSION
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
COPY --from=downloader /tmp/bellsoft.key /tmp/bellsoft.key
COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 assets/tmp/requirements.txt /tmp/requirements.txt
COPY --chown=1000:1000 --from=downloader /tmp/ierl /tmp/ierl 
COPY --chown=1000:1000 --from=downloader /tmp/rust_setup.sh /tmp/rust_setup.sh
COPY --from=downloader /tmp/setup_nodejs.sh /tmp/setup_nodejs.sh
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
        unzip \
        xz-utils \
        zlib1g-dev \
        tk-dev \
        uuid-dev"

COPY --chown=1000:1000 --from=downloader /tmp/coursier /usr/local/bin/cs

RUN chmod +x /usr/local/bin/cs

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
 && curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A1715D88E1DF1F24 \
 && echo "deb http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && echo "deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ ${UBUNTU_CODENAME} main" >> /etc/apt/sources.list.d/git-core.list \
 && chmod +x /tmp/setup_nodejs.sh \
 && /tmp/setup_nodejs.sh \
 && dpkg -i /tmp/erlang-solutions_all.deb \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends "bellsoft-java${JDK_MAJOR_VERSION}-full" ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/llvm-snapshot.gpg.key /tmp/setup_nodejs.sh

RUN npm install -g npm \
 && npm install -g yarn configurable-http-proxy \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && pip3 install --no-cache-dir -U pip \
 && pip3 install --no-cache-dir -U setuptools \
 && pip install --no-cache-dir -r /tmp/requirements.txt \
 && rm -f /tmp/requirements.txt

RUN jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && npm -g i tslab \
 && tslab install

WORKDIR /tmp

RUN chmod u+x ierl \
 && ./ierl install elixir \
 && ./ierl install lfe \
 && ./ierl install erlang \
 && ln -s "/usr/bin/clang-${LLVM_VERSION}" /usr/bin/clang \
 && groupadd -g 1000 "${USER_NAME}" \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 "${USER_NAME}" \
 && SCALA_SHORT_VERSION="$(echo ${SCALA_VERSION} | cut -f1-2 -d.)" \
 && SCALA_SHORT_VERSION_TRIMMED="$(echo ${SCALA_SHORT_VERSION} | tr -d .)" \
 && echo "Installing almond ${ALMOND_VERSION} for Scala ${SCALA_SHORT_VERSION}" \
 && echo "${SCALA_SHORT_VERSION}" \
 && cs bootstrap \
      -r jitpack \
      -i user -I "user:sh.almond:scala-kernel-api_${SCALA_VERSION}:${ALMOND_VERSION}" \
      "sh.almond:scala-kernel_${SCALA_VERSION}:${ALMOND_VERSION}" \
      --default=true --sources \
      -o almond \
 && ./almond --install --log info --metabrowse --id "scala${SCALA_SHORT_VERSION}" \
      --global \
      --display-name "Scala (${SCALA_SHORT_VERSION})" \
 && rm -f almond \
 && cs bootstrap \
      -r jitpack \
      -i user -I "user:sh.almond:scala-kernel-api_${SCALA3_VERSION}:${ALMOND_VERSION}" \
      "sh.almond:scala-kernel_${SCALA3_VERSION}:${ALMOND_VERSION}" \
      --default=true --sources \
      -o almond \
 && ./almond --install --log info --metabrowse --id scala$(echo ${SCALA3_VERSION} | cut -f1-2 -d. | tr -d .) \
      --global \
      --display-name "Scala ($(echo ${SCALA3_VERSION} | cut -f1-2 -d.))" \
 && rm -f almond

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
