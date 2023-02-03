ARG DISTRIBUTION="debian"
ARG DEBIAN_CODENAME="bullseye"
ARG UBUNTU_CODENAME="focal"

ARG JAVA_VERSION=11
ARG SBT_VERSION="1.8.1"
ARG SCALA_VERSION="2.13.10"
ARG SCALA3_VERSION="3.1.3"
ARG SBT_HOME=/usr/local/sbt
ARG ALMOND_VERSION="0.13.3"
ARG PYTHON_VERSION=3.11
ARG LLVM_VERSION=15

FROM buildpack-deps:${DEBIAN_CODENAME}-curl AS downloader

ARG SBT_VERSION

WORKDIR /tmp

RUN apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install -qqy --no-install-recommends unzip \
 && ARCH=$(dpkg --print-architecture) \
 && if [ "${ARCH}" = "arm64" ]; then ARCH="aarch64"; fi \
 && curl -sSLo /tmp/bellsoft.key https://download.bell-sw.com/pki/GPG-KEY-bellsoft \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -fsSLo /tmp/coursier https://github.com/coursier/launchers/raw/master/cs-${ARCH}-pc-linux


FROM python:${PYTHON_VERSION}-${DEBIAN_CODENAME} AS base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ENV DEBIAN_FRONTEND noninteractive

USER root

ARG DEBIAN_CODENAME
ARG UBUNTU_CODENAME

ARG PYTHON_VERSION
ARG LLVM_VERSION

ARG DEPENDENCIES="\
    libcurl4-openssl-dev \
    libssl-dev \
    build-essential \
    cmake \
    git \
    clang-${LLVM_VERSION} \
    clang++-${LLVM_VERSION} \
    lld-${LLVM_VERSION} \
    nodejs \
    patch \
    ca-certificates \
    software-properties-common"

ARG JAVA_VERSION

ARG SBT_HOME

ENV COURSIER_BIN_DIR="/usr/local/bin" \
    COURSIER_CACHE="/usr/share/coursier/cache" \
    SBT_HOME="${SBT_HOME}" \
    PATH="${PATH}:${SBT_HOME}/bin:/usr/local/bin" \
    CC="/usr/bin/clang-${LLVM_VERSION}" \
    CXX="/usr/bin/clang++-${LLVM_VERSION}"

COPY --from=downloader /tmp/bellsoft.key /tmp/bellsoft.key
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 --from=downloader /tmp/coursier /usr/local/bin/cs

# Install Python and Jupyter
RUN rm -rf /var/lib/apt/lists/* \
 && apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && cat /tmp/bellsoft.key | apt-key add - \
 && rm -rf /tmp/bellsoft.key \
 && echo "deb [arch=$(dpkg --print-architecture)] https://apt.bell-sw.com/ stable main" > /etc/apt/sources.list.d/bell-sw.list \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys A1715D88E1DF1F24 \
 && echo "deb http://apt.llvm.org/${DEBIAN_CODENAME}/ llvm-toolchain-${DEBIAN_CODENAME}-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && echo "deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ ${UBUNTU_CODENAME} main" >> /etc/apt/sources.list.d/git-core.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends "bellsoft-java${JAVA_VERSION}-full" ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/llvm-snapshot.gpg.key

RUN chmod +x /usr/local/bin/cs \
 && mkdir -p "${COURSIER_CACHE}" \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && pip3 install --no-cache-dir -U pip \
 && pip --no-cache-dir install -U setuptools \
 && pip --no-cache-dir install -U jupyter notebook jupyterlab jupyterhub \
    jupyter_core jupyter_client \
    sqlalchemy tornado jinja2 traitlets requests \
 && rm -rf /tmp/*

FROM base

ARG SCALA_VERSION
ARG SCALA_FULL_VERSION="${SCALA_VERSION}"

RUN cs install scala scala3-compiler scala3-repl

RUN groupadd -g 1000 java \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 java

USER java

ENV PATH="${PATH}:/home/java/.local/bin"

ARG SCALA3_VERSION
ARG ALMOND_VERSION

USER java

RUN mkdir -p /home/java/notebook \
 && jupyter notebook --generate-config

USER root

RUN SCALA_SHORT_VERSION="$(echo ${SCALA_VERSION} | cut -f1-2 -d.)" \
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

USER java

COPY --chown=1000:1000 jupyter_notebook_config.py /home/java/.jupyter/jupyter_notebook_config.py

WORKDIR /home/java/notebook

COPY jupyter_notebook_config.py /home/java/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

CMD ["jupyter", "notebook"]
