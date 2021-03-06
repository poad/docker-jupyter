ARG SBT_VERSION=1.4.1
ARG SCALA_VERSION=2.13.3
ARG SBT_HOME=/usr/local/sbt
ARG SCALA_HOME=/usr/local/scala
ARG ALMOND_VERSION=0.10.9

FROM alpine:3 AS downloader

ARG SBT_VERSION
ARG SCALA_VERSION
ARG SBT_HOME
ARG SCALA_HOME

WORKDIR /tmp

RUN apk --update add --no-cache --virtual .build-deps \
    git \
    curl \
    gnupg \
    xz \
 && rm -rf /var/cache/apk/* \
 && curl -sSL "https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz"         | tar -xz -C /usr/local \
 && mv ${SCALA_HOME}-${SCALA_VERSION} ${SCALA_HOME} \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && git clone https://github.com/almond-sh/almond.git \
 && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py


FROM poad/docker-openjdk:15

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
     ca-certificates"

# Install sbt and almond
ARG SBT_HOME
ARG SCALA_HOME
ARG SCALA_VERSION
ARG ALMOND_VERSION

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

# Install Python and Jupyter
RUN apt-get update  -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && python3 /tmp/get-pip.py \
 && pip --no-cache-dir install -U setuptools \
 && pip --no-cache-dir install -U jupyter notebook jupyterlab jupyterhub \
          sqlalchemy tornado jinja2 traitlets requests \
          jupyter_core jupyter_client \
 && jupyter notebook --generate-config --allow-root \
 && apt-get -qqy autoremove --purge ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*

COPY --chown=1000:1000 --from=downloader /tmp/almond /tmp/almond

WORKDIR /tmp/almond/project

# Install Python and Jupyter
RUN mv build.properties build.properties.bak \
 && sed -e "s/1\.3\.3/${SBT_VERSION}/g" build.properties.bak > build.properties \
 && rm -f build.properties.bak

COPY --from=downloader ${SCALA_HOME} ${SCALA_HOME}
COPY --from=downloader ${SBT_HOME} ${SBT_HOME}

ENV SBT_HOME="${SBT_HOME}" \
    SCALA_HOME="${SCALA_HOME}" \
    PATH=${PATH}:${SBT_HOME}/bin:${SCALA_HOME}/bin

WORKDIR /tmp/almond
RUN apt-get update  -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && bash scripts/coursier.sh bootstrap \
        -r jitpack \
        -i user -I user:sh.almond:scala-kernel-api_${SCALA_VERSION}:${ALMOND_VERSION} \
        sh.almond:scala-kernel_${SCALA_VERSION}:${ALMOND_VERSION} \
        -o almond \
 && ./almond --install \
 && rm -rf almond \
 && apt-get -qqy autoremove --purge ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*

USER java

RUN mkdir -p /home/java/notebook

COPY --chown=1000:1000 jupyter_notebook_config.py /home/java/.jupyter/jupyter_notebook_config.py

WORKDIR /home/java/notebook

COPY jupyter_notebook_config.py /home/java//.jupyter/jupyter_notebook_config.py

EXPOSE 8888

CMD ["jupyter", "notebook"]
