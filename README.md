[![Docker Automated build](https://img.shields.io/docker/cloud/automated/poad/docker-jupyter?style=flat-square)](https://hub.docker.com/r/poad/docker-jupyter)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/poad/docker-jupyter)](https://hub.docker.com/r/poad/docker-jupyter/builds)

# About

The Docker image for Jupyter notebook with any languages

# Tags

## All in one based JDK8

```$sh
docker pull poad/docker-jupyter:all-in-one-jdk8
```

Jupyter notebook with follow kernels based JDK8

- scala ([almond](https://almond.sh))
- rust ([evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter))
- Erlang ([ierl](https://github.com/filmor/ierl))
- Elixir ([ierl](https://github.com/filmor/ierl))
- LFE ([ierl](https://github.com/filmor/ierl))

## All in one based JDK11

```$sh
docker pull poad/docker-jupyter:all-in-one-jdk11
```

Jupyter notebook with follow kernels based JDK11

- scala ([almond](https://almond.sh))
- rust ([evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter))
- Erlang ([ierl](https://github.com/filmor/ierl))
- Elixir ([ierl](https://github.com/filmor/ierl))
- LFE ([ierl](https://github.com/filmor/ierl))

## Java

```$sh
docker pull poad/docker-jupyter:java
```

Jupyter notebook with [IJava](https://github.com/SpencerPark/IJava) kernel

## Rust

```$sh
docker pull poad/docker-jupyter:rust
```

Jupyter notebook with [evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter)

## Scala

```$sh
docker pull poad/docker-jupyter:scala
```

Jupyter notebook with [almond](https://almond.sh)
