# Jupyter lab container images

[![Docker build and push](https://github.com/poad/docker-jupyter/actions/workflows/main.yml/badge.svg)](https://github.com/poad/docker-jupyter/actions/workflows/main.yml)

## About

The Docker image for Jupyter notebook with any languages

## Tags

### All in one based JDK 8

```$sh
docker pull poad/docker-jupyter:all-in-one-jdk8
```

Jupyter notebook with follow kernels based JDK 8

- Scala ([almond](https://almond.sh))
- Rust ([evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter))
- Erlang ([ierl](https://github.com/filmor/ierl))
- Elixir ([ierl](https://github.com/filmor/ierl))
- LFE ([ierl](https://github.com/filmor/ierl))
- Node.js/TypeScript ([tslab](https://github.com/yunabe/tslab))

### All in one based JDK 11

```$sh
docker pull poad/docker-jupyter:all-in-one-jdk11
```

Jupyter notebook with follow kernels based JDK 11

- scala ([almond](https://almond.sh))
- rust ([evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter))
- Erlang ([ierl](https://github.com/filmor/ierl))
- Elixir ([ierl](https://github.com/filmor/ierl))
- LFE ([ierl](https://github.com/filmor/ierl))
- Node.js/TypeScript ([tslab](https://github.com/yunabe/tslab))

### All in one based JDK 17

```$sh
docker pull poad/docker-jupyter:all-in-one-jdk17
```

Jupyter notebook with follow kernels based JDK 17

- scala ([almond](https://almond.sh))
- rust ([evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter))
- Erlang ([ierl](https://github.com/filmor/ierl))
- Elixir ([ierl](https://github.com/filmor/ierl))
- LFE ([ierl](https://github.com/filmor/ierl))
- Node.js/TypeScript ([tslab](https://github.com/yunabe/tslab))

### Java

```$sh
docker pull poad/docker-jupyter:java
```

Jupyter notebook with [IJava](https://github.com/SpencerPark/IJava) kernel

### Rust

```$sh
docker pull poad/docker-jupyter:rust
```

Jupyter notebook with [evcxr](https://github.com/google/evcxr/tree/master/evcxr_jupyter)

### Scala

```$sh
docker pull poad/docker-jupyter:scala
```

Jupyter notebook with [almond](https://almond.sh)

### Node.js

```$sh
docker pull poad/docker-jupyter:nodejs
```

Jupyter notebook with JavaScript ([tslab](https://github.com/yunabe/tslab))

### TypeScript

```$sh
docker pull poad/docker-jupyter:typescript
```

Jupyter notebook with TypeScript ([tslab](https://github.com/yunabe/tslab))
