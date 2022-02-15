ARG JAVA_VERSION=11
ARG SBT_VERSION="1.6.1"
ARG SCALA_VERSION="2.13.4"
# ARG SCALA2_LATEST_VERSION="2.13.7"
# ARG SCALA3_VERSION="3.0.4"
ARG SBT_HOME=/usr/local/sbt
ARG ALMOND_VERSION="0.11.2"
ARG PYTHON_VERSION=3.10
ARG LLVM_VERSION=13

FROM alpine:3 AS downloader

ARG SBT_VERSION

WORKDIR /tmp

RUN ARCH=$(apk --print-arch) \
 && apk --update add --no-cache --virtual .build-deps \
    git \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/* \
 && curl -sSLo /tmp/corretto.key https://apt.corretto.aws/corretto.key \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
 && curl -fLo /tmp/coursier https://github.com/coursier/launchers/raw/master/cs-${ARCH}-pc-linux


FROM ubuntu:focal AS base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ENV DEBIAN_FRONTEND noninteractive

USER root

ARG PYTHON_VERSION
ARG LLVM_VERSION

ARG DEPENDENCIES="\
    libcurl4-openssl-dev \
    libssl-dev \
    build-essential \
    git \
    clang-${LLVM_VERSION} \
    clang++-${LLVM_VERSION} \
    lld-${LLVM_VERSION} \
    nodejs \
    patch \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-distutils \
    libpython${PYTHON_VERSION}-dev \
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

COPY --from=downloader /tmp/corretto.key /tmp/corretto.key
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 --from=downloader /tmp/coursier /usr/local/bin/cs

# Install Python and Jupyter
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && cat /tmp/corretto.key | apt-key add - \
 && rm -rf /tmp/corretto.key \
 && echo "deb https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/aws-corretto.list \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && add-apt-repository ppa:git-core/ppa -y \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends "java-${JAVA_VERSION}-amazon-corretto-jdk" ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/llvm-snapshot.gpg.key

RUN chmod +x /usr/local/bin/cs \
 && mkdir -p "${COURSIER_CACHE}" \
 && update-alternatives --install "/usr/bin/python3" "python3" "/usr/bin/python${PYTHON_VERSION}" 31000 \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && python3 /tmp/get-pip.py --no-cache-dir pip==21.3 \
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

# ARG SCALA2_LATEST_VERSION
# ARG SCALA3_VERSION
ARG ALMOND_VERSION

USER java

RUN mkdir -p /home/java/notebook \
 && jupyter notebook --generate-config

USER root

RUN SCALA_MAJOR_VERSION="$(echo ${SCALA_VERSION} | cut -f1-2 -d.)" \
 && SCALA_MAJOR_VERSION_TRIMMED="$(echo ${SCALA_MAJOR_VERSION} | tr -d .)" \
 && echo "Installing almond ${ALMOND_VERSION} for Scala ${SCALA_FULL_VERSION}" \
 && echo "${SCALA_MAJOR_VERSION_TRIMMED}" \
 && cs bootstrap \
      -r jitpack \
      -i user -I "user:sh.almond:scala-kernel-api_${SCALA_FULL_VERSION}:${ALMOND_VERSION}" \
      "sh.almond:scala-kernel_${SCALA_FULL_VERSION}:${ALMOND_VERSION}" \
    -M almond.ScalaKernel \
      --default=true --sources \
 && cs launch --fork almond:"${ALMOND_VERSION}" -M almond.ScalaKernel --scala "${SCALA_FULL_VERSION}" -- --install \
     --id "scala${SCALA_MAJOR_VERSION_TRIMMED}" --display-name "Scala (${SCALA_MAJOR_VERSION})"

# RUN echo "Installing almond ${ALMOND_VERSION} for Scala ${SCALA2_LATEST_VERSION}" \
#  && cs launch --fork "almond:${ALMOND_VERSION}" -M almond.ScalaKernel --scala "${SCALA2_LATEST_VERSION}" -- --install \
#       --id "scala2-latest" --display-name "Scala (2.x latest)"

# RUN echo "Installing almond ${ALMOND_VERSION} for Scala ${SCALA3_VERSION}" \
#  && echo "${SCALA3_VERSION}" | cut -f1-2 -d.  | tr -d . \
#  && cs launch --fork "almond:${ALMOND_VERSION}" -M almond.ScalaKernel --scala "${SCALA3_VERSION}" -- --install \
#       --id "scala$(echo ${SCALA3_VERSION} | cut -f1-2 -d.  | tr -d .)" --display-name "Scala ($(echo ${SCALA3_VERSION} | cut -f1-2 -d.))"

USER java

COPY --chown=1000:1000 jupyter_notebook_config.py /home/java/.jupyter/jupyter_notebook_config.py

WORKDIR /home/java/notebook

COPY jupyter_notebook_config.py /home/java/.jupyter/jupyter_notebook_config.py

EXPOSE 8888

CMD ["jupyter", "notebook"]
