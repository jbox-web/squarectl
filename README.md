# squarectl

[![GitHub License](https://img.shields.io/github/license/jbox-web/squarectl)](https://github.com/jbox-web/squarectl/blob/master/LICENSE)
[![Build Status](https://github.com/jbox-web/squarectl/actions/workflows/ci.yml/badge.svg)](https://github.com/jbox-web/squarectl/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/jbox-web/squarectl)](https://github.com/jbox-web/squarectl/releases/latest)
[![Docker Image](https://img.shields.io/docker/v/nicoladmin/squarectl/latest?color=green&label=Docker%20Image&logo=docker)](https://hub.docker.com/r/nicoladmin/squarectl)

`squarectl` is a command-line tool that unifies application deployment across
**Docker Compose**, **Docker Swarm** and **Kubernetes** from a single configuration file.

From a `squarectl.yml` describing your application and its environments
(`development`, `staging`, `production`, ...), squarectl assembles the right list of compose files,
environment variables, networks, SSL certificates, configs and secrets, then runs the underlying
command (`docker compose`, `docker stack`, `kubectl`, `kompose`).

## Installation

### Manual installation

Grab the latest binary from the [releases](https://github.com/jbox-web/squarectl/releases) page and run it with the [sample configuration project](https://github.com/jbox-web/squarectl/tree/master/example).

If you use [asdf](https://github.com/asdf-vm/asdf) you can also install squarectl with [asdf-squarectl](https://github.com/jbox-web/asdf-squarectl).

### Setup Bash completion

Add this to your .bashrc

```sh
source <(squarectl completion bash)
```

## Usage

Every command targets a **target** (`compose`, `swarm`, `kube`) and takes an **environment** as an
argument. The configuration file defaults to `squarectl.yml` (use `--config`/`-c` to change it):

```sh
# Docker Compose
squarectl compose config staging      # print the resolved compose configuration
squarectl compose build staging       # build the images
squarectl compose up staging          # create SSL certificates + networks, then start the stack
squarectl compose down staging        # stop the stack
squarectl compose exec staging <svc>  # run a command inside a service
squarectl compose clean staging       # stop everything and remove networks + certificates

# Docker Swarm
squarectl swarm deploy production      # docker stack deploy
squarectl swarm destroy production     # docker stack rm
squarectl configs create production    # manage Docker Swarm Configs
squarectl secrets create production    # manage Docker Swarm Secrets

# Kubernetes
squarectl kube convert production -o out/   # convert the compose config to manifests (kompose)
squarectl kube deploy production            # kubectl apply

# Misc
squarectl info compose staging   # print the resolved configuration for a target/environment
```

Arguments after the environment are passed through as-is to the underlying tool
(e.g. `squarectl compose up staging --detach`). Export `SQUARECTL_DEBUG=true` to print the full
command line and environment instead of running it blindly.

## Development

The project is written in [Crystal](https://crystal-lang.org) and the development environment is
managed by [mise](https://mise.jdx.dev) (see `mise.toml`):

```sh
mise dev:deps     # install dependencies (shards install)
mise dev:build    # compile a development binary into bin/
mise dev:spec     # run the test suite
mise dev:ameba    # static code analysis
mise dev:format   # format the code
```

Release binaries (static, multi-arch) are produced via `mise release:static`
(Docker Buildx / `docker-bake.hcl`).
