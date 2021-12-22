ARG JAVA_VERSION=8
ARG SBT_VERSION="1.5.8"
ARG SCALA_VERSION="2.13.4"
ARG SBT_HOME=/usr/local/sbt
ARG ALMOND_VERSION="0.11.1"

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
RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-get -qqy autoremove --purge ${DEPENDENCIES} \
 && apt-get install -qqy --no-install-recommends python3.9 python3.9-distutils \
 && update-alternatives --install "/usr/bin/python3" "python3" "/usr/bin/python3.9" 3900 \
 && update-alternatives --install "/usr/bin/python" "python" "/usr/bin/python3" 3900 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --chown=1000:1000 --from=downloader /tmp/coursier /usr/local/bin/cs

RUN chmod +x /usr/local/bin/cs

RUN mkdir -p "${COURSIER_CACHE}" \
 && python3 /tmp/get-pip.py \
 && pip --no-cache-dir install -U setuptools \
 && rm -rf /tmp/* \
 && pip --no-cache-dir install -U jupyter notebook jupyterlab jupyterhub \
          sqlalchemy tornado jinja2 traitlets requests \
          jupyter_core jupyter_client \
 && jupyter notebook --generate-config --allow-root

ARG SCALA_VERSION
ARG SCALA_FULL_VERSION="${SCALA_VERSION}"

RUN cs install scala scala3-compiler scala3-repl


FROM base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ARG SCALA_VERSION
ARG SCALA_FULL_VERSION="${SCALA_VERSION}"
ARG ALMOND_VERSION

RUN SCALA_MAJOR_VERSION="${SCALA_VERSION%.*}" \
 && SCALA_MAJOR_VERSION_TRIMMED=$(echo "${SCALA_MAJOR_VERSION}" | tr -d .) \
 && echo "Installing almond ${ALMOND_VERSION} for Scala ${SCALA_FULL_VERSION}" \
 && echo "${SCALA_MAJOR_VERSION_TRIMMED}" \
 && cs bootstrap \
      -r jitpack \
      -i user -I user:sh.almond:scala-kernel-api_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      sh.almond:scala-kernel_${SCALA_FULL_VERSION}:${ALMOND_VERSION} \
      --default=true --sources \
 && cs launch --fork almond:"${ALMOND_VERSION}" --scala "${SCALA_FULL_VERSION}" -- --install \
      --id "scala${SCALA_MAJOR_VERSION_TRIMMED}" --display-name "Scala ${SCALA_MAJOR_VERSION}" \
 && groupadd -g 1000 java \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 java

USER java

RUN mkdir -p /home/java/notebook

COPY --chown=1000:1000 jupyter_notebook_config.py /home/java/.jupyter/jupyter_notebook_config.py

WORKDIR /home/java/notebook

COPY jupyter_notebook_config.py /home/java//.jupyter/jupyter_notebook_config.py

EXPOSE 8888

CMD ["jupyter", "notebook"]
