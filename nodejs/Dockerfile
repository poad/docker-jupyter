ARG UBUNTU_CODENAME="focal"

ARG NODE_VERSION="16.x"

FROM buildpack-deps:${UBUNTU_CODENAME}-curl AS downloader

ARG NODE_VERSION

RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
 && curl -sLo /tmp/setup_nodejs.sh "https://deb.nodesource.com/setup_${NODE_VERSION}"

FROM buildpack-deps:${UBUNTU_CODENAME}-curl AS base

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG USER_NAME="node"
ARG USER_HOME=/home/${USER_NAME}

ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

USER root

WORKDIR /tmp

COPY --chown=1000:1000 requirements.txt /tmp/requirements.txt
COPY --from=downloader /tmp/setup_nodejs.sh /tmp/setup_nodejs.sh
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

ARG DEPENDENCIES="\
  autoconf \
  automake \
  bzip2 \
  dpkg-dev \
  file \
  gcc \
  git \
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
  python3-dev \
  python3.9 \
  python3.9-dev \
  libpython3.9-dev \
  unzip \
  xz-utils \
  zlib1g-dev \
  tk-dev \
  uuid-dev"

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && add-apt-repository ppa:git-core/ppa -y \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && chmod +x /tmp/setup_nodejs.sh \
 && /tmp/setup_nodejs.sh \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends ${DEPENDENCIES} \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists

RUN python3 /tmp/get-pip.py --no-cache-dir \
 && pip3 install --no-cache-dir -U pip \
 && pip install --no-cache-dir -U setuptools \
 && npm -g i npm \
 && npm install -g yarn configurable-http-proxy
# RUN npm -g i ijavascript-plotly

RUN pip install --no-cache-dir -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && rm -f /tmp/requirements.txt /tmp/get-pip.py \
 && groupadd -g 1000 "${USER_NAME}" \
 && useradd -g 1000 -l -m -s /bin/false -u 1000 "${USER_NAME}"

# RUN jupyter labextension install jupyterlab-plotly @jupyter-widgets/jupyterlab-manager plotlywidget

USER ${USER_NAME}

ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8 "
ENV PATH="${PATH}:/usr/local/bin"

WORKDIR /tmp

RUN jupyter notebook --generate-config \
 && mkdir -p "${USER_HOME}/.jupyter" \
 && mkdir -p "${USER_HOME}/notebook" \
 && chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}"

COPY --chown=1000:1000 jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

WORKDIR ${USER_HOME}/notebook

HEALTHCHECK CMD [ "npm", "--version" ]

EXPOSE 8888

CMD ["jupyter", "lab"]
