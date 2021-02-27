FROM alpine:3 AS downloader

RUN apk --update add --no-cache \
        curl \
 && curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py

FROM alpine:3

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ARG USER_NAME=node
ARG USER_HOME=/home/${USER_NAME}

RUN addgroup -g 1000 -S "${USER_NAME}" \
 && adduser -u 1000 -S  "${USER_NAME}" -G "${USER_NAME}"


COPY requirements.txt /tmp/requirements.txt
COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

RUN apk --update add --no-cache --virtual \
        build-base \
        bash \
        ca-certificates \
        cargo \
        cmake \
        curl \
        czmq-dev \
        freetype-dev \
        gcc \
        g++ \
        git \
        gnupg \
        libssl1.1 \
        libzmq \
        libffi-dev \
        libxml2-dev \
        libxslt-dev \
        libpng-dev \
        m4 \
        make \
        musl-dev \
        npm \
        nodejs \
        openssl-dev \
        py3-pyzmq \
        python3 \
        python3-dev \
        rsync \
        unzip \
        zlib \
 && rm -rf /var/cache/apk/*
RUN npm i -g n yarn \
 && n lts \
 && python3 /tmp/get-pip.py \
 && pip install -U setuptools \
 && pip install -r /tmp/requirements.txt \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter nbextension enable --py widgetsnbextension \
 && npm install -g --unsafe-perm ijavascript \
 && ijsinstall --install=global \
 && rm -rf /tmp/get-pip.py

USER ${USER_NAME}

WORKDIR ${USER_HOME}

RUN jupyter notebook --generate-config --allow-root

RUN mkdir -p ${USER_HOME}/.jupyter

ADD jupyter_notebook_config.py ${USER_HOME}/.jupyter/jupyter_notebook_config.py

RUN mkdir -p ${USER_HOME}/notebook
WORKDIR ${USER_HOME}/notebook

HEALTHCHECK CMD [ "npm", "--version" ]

EXPOSE 8888

CMD ["jupyter", "lab"]
