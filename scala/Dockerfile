ARG JAVA_VERSION=8
ARG SBT_VERSION="1.6.1"
ARG SCALA_VERSION="2.13.4"
# ARG SCALA2_LATEST_VERSION="2.13.7"
# ARG SCALA3_VERSION="3.0.4"
ARG SBT_HOME=/usr/local/sbt
ARG ALMOND_VERSION="0.11.2"
ARG PYTHON_VERSION=3.10

FROM alpine:3 AS downloader

ARG SBT_VERSION

WORKDIR /tmp

RUN apk --update add --no-cache --virtual .build-deps \
    git \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/*

RUN curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && curl -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
 && curl -fLo /tmp/coursier https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux


FROM mcr.microsoft.com/java/jdk:${JAVA_VERSION}-zulu-ubuntu AS JDK

FROM ubuntu:focal AS base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ENV DEBIAN_FRONTEND noninteractive

USER root

ARG DEPENDENCIES="\
     curl \
     libcurl4-openssl-dev \
     libssl-dev \
     build-essential \
     python3 \
     python3-distutils \
     ca-certificates \
     software-properties-common"

ARG JAVA_VERSION

ARG JAVA_HOME_DIR=java-${JAVA_VERSION}-openjdk-amd64
ARG SBT_HOME
ARG PYTHON_VERSION

ENV COURSIER_BIN_DIR="/usr/local/bin" \
    COURSIER_CACHE="/usr/share/coursier/cache" \
    SBT_HOME="${SBT_HOME}" \
    PATH=${PATH}:${SBT_HOME}/bin \
    JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64

ARG basedir=${JAVA_HOME}
ARG mandir=${basedir}/man

COPY --from=JDK /usr/lib/jvm/zulu-${JAVA_VERSION}-azure-amd64 ${JAVA_HOME}
RUN set -ex; \
	\
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
    mkdir -p /usr/lib/jvm/; \
    cd "${basedir}/bin"; \
    for i in *; do \
        update-alternatives --install "/usr/bin/${i}" "${i}" "$basedir/bin/${i}" 1100; \
    done \
 && \
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
    update-alternatives --get-selections | awk -v home="$(readlink -f "${JAVA_HOME}")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual'

ENV PATH ${JAVA_HOME}/bin:${PATH}

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

# Install Python and Jupyter
RUN \
 --mount=type=cache,target=/var/cache/apt \
 --mount=type=cache,target=/var/lib/apt \
 apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-get -qqy autoremove --purge ${DEPENDENCIES} \
 && apt-get install -qqy --no-install-recommends "python${PYTHON_VERSION}" "python${PYTHON_VERSION}-distutils" \
 && update-alternatives --install "/usr/bin/python3" "python3" "/usr/bin/python${PYTHON_VERSION}" 31000 \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 31000 \
 && apt-get clean

COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 --from=downloader /tmp/coursier /usr/local/bin/cs

RUN chmod +x /usr/local/bin/cs

RUN mkdir -p "${COURSIER_CACHE}" \
 && python3 /tmp/get-pip.py \
 && pip --no-cache-dir install -U setuptools \
 && pip --no-cache-dir install -U jupyter notebook jupyterlab jupyterhub \
    jupyter_core jupyter_client \
    sqlalchemy tornado jinja2 traitlets requests \
&& rm -rf /tmp/*

ARG SCALA_VERSION
ARG SCALA_FULL_VERSION="${SCALA_VERSION}"

RUN cs install scala scala3-compiler scala3-repl

RUN groupadd -g 1000 java \
    && useradd -g 1000 -l -m -s /bin/false -u 1000 java

USER java

ENV PATH="${PATH}:/home/java/.local/bin"

FROM base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ARG SCALA_VERSION
ARG SCALA_FULL_VERSION="${SCALA_VERSION}"
# ARG SCALA2_LATEST_VERSION
# ARG SCALA3_VERSION
ARG ALMOND_VERSION
ARG PYTHON_VERSION

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
