ARG SBT_VERSION=1.3.6
ARG SCALA_VERSION=2.13.1
ARG SBT_HOME=/usr/local/sbt
ARG SCALA_HOME=/usr/local/scala

FROM alpine:latest AS downloader

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
 && curl -sL "https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" | tar -xz -C /usr/local \
 && mv ${SCALA_HOME}-${SCALA_VERSION} ${SCALA_HOME} \
 && curl -sL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /usr/local \
 && git clone https://github.com/almond-sh/almond.git


FROM poad/docker-openjdk:13

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ENV DEBIAN_FRONTEND noninteractive

USER root

ARG DEPENDENCIES="\
     curl \
     libcurl4-openssl-dev \
     libssl-dev \
     build-essential"

# Install sbt and almond
ARG SBT_HOME
ARG SCALA_HOME
ARG SCALA_VERSION
ARG ALMOND_VERSION=0.9.1

COPY --from=downloader ${SBT_HOME} ${SBT_HOME}
COPY --from=downloader ${SCALA_HOME} ${SCALA_HOME}
COPY --chown=1000:1000 --from=downloader /tmp/almond /tmp/almond

ENV SBT_HOME="${SBT_HOME}" \
    SCALA_HOME="${SCALA_HOME}" \
    PATH=${PATH}:${SBT_HOME}/bin:${SCALA_HOME}/bin

WORKDIR /tmp/almond/project

# Install Python and Jupyter
RUN apt-get update  -qq\
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && pip3 --no-cache-dir install -U setuptools pip \
 && pip3 --no-cache-dir install -U jupyter notebook jupyterlab jupyterhub \
          sqlalchemy tornado jinja2 traitlets requests \
          jupyter_core jupyter_client \
 && jupyter notebook --generate-config --allow-root \
 && mv build.properties build.properties.bak \
 && sed -e "s/1\.3\.3/${SBT_VERSION}/g" build.properties.bak > build.properties \
 && rm -f build.properties.bak \
 && cd ../ \
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
