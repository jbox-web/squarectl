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

### With mise (recommended)

squarectl is published as an [aqua](https://aquaproj.github.io) package in the JBox aqua registry
([`jbox-web/aqua-registry`](https://github.com/jbox-web/aqua-registry)) and installed with
[mise](https://mise.jdx.dev).

Add it to a project by pointing the aqua backend at the registry and declaring the tool in
`mise.toml`:

```toml
[settings]
aqua.registries = ["https://github.com/jbox-web/aqua-registry"]

[tools]
"aqua:jbox-web/squarectl" = "latest"
```

```sh
mise install
```

Or install it globally:

```sh
mise settings add aqua.registries https://github.com/jbox-web/aqua-registry
mise use -g "aqua:jbox-web/squarectl@latest"
```

### Manual download

Alternatively, grab the latest static binary from the
[releases](https://github.com/jbox-web/squarectl/releases) page.

### Setup Bash completion

Add this to your .bashrc

```sh
source <(squarectl completion bash)
```

## Usage

Every command targets a **target** (`compose`, `swarm`, `kube`) and takes an **environment** as an
argument. The configuration file defaults to `squarectl.yml` (use `--config`/`-c` to change it):

```sh
# Docker Compose (target: compose)
squarectl compose config staging       # print the resolved compose configuration
squarectl compose build staging        # build the images
squarectl compose push staging         # push the images
squarectl compose up staging           # create SSL certificates + networks, then start the stack
squarectl compose down staging         # stop the stack
squarectl compose start staging        # start existing containers
squarectl compose stop staging         # stop running containers
squarectl compose ps staging           # list containers
squarectl compose top staging          # show running processes
squarectl compose exec staging <svc>   # run a command inside a service
squarectl compose cp staging <args>    # copy files to/from a container
squarectl compose setup staging        # run the environment setup_commands
squarectl compose clean staging        # stop everything and remove networks + certificates

# Docker Swarm (target: swarm)
squarectl swarm config production      # print the resolved compose configuration
squarectl swarm build production       # build the images
squarectl swarm push production        # push the images
squarectl swarm deploy production      # docker stack deploy
squarectl swarm setup production       # run the environment setup_commands
squarectl swarm destroy production     # docker stack rm
squarectl swarm clean production       # remove networks + certificates
squarectl configs create production    # manage Docker Swarm Configs   (create | destroy)
squarectl secrets create production    # manage Docker Swarm Secrets   (create | destroy)

# Kubernetes (target: kube)
squarectl kube config production            # print the resolved compose configuration
squarectl kube build production             # build the images
squarectl kube push production              # push the images
squarectl kube convert production -o out/   # convert the compose config to manifests (kompose)
squarectl kube deploy production            # kubectl apply
squarectl kube setup production             # run the setup_commands via kubectl exec
squarectl kube clean production             # remove networks + certificates

# Misc
squarectl info compose staging   # print the resolved configuration for a target/environment
                                 #   (info also accepts: swarm, kube)
squarectl completion bash        # print the Bash completion script
squarectl --version              # print the version
```

Arguments after the environment are passed through as-is to the underlying tool
(e.g. `squarectl compose up staging --detach`). Export `SQUARECTL_DEBUG=true` to print the full
command line and environment (as YAML) *before* each command runs — this is not a dry run, the
command still executes. The dump includes every environment variable, so avoid it when the
environment holds secrets.

squarectl shells out to the underlying tools (`docker`, `docker compose`/`docker stack`, `kubectl`,
`kompose`), so they must be on your `PATH`. For local development, `compose up` also generates the
declared SSL certificates automatically with [mkcert](https://github.com/FiloSottile/mkcert) (and
removes them on `compose clean`) — just keep `mkcert` on your `PATH`, there is no manual certificate
generation to do.

## Configuration

squarectl reads a single YAML file (`squarectl.yml` by default). The file is first rendered as a
[Crinja](https://github.com/straight-shoota/crinja) (Jinja2) template with access to the process
environment (`{{ ENV['MYAPP_RELEASE'] }}`), then parsed.

A complete, runnable sample project lives in [`example/`](example) — a minimal `blog` app wired for
the `compose` and `swarm` targets.

### Top level

```yaml
app: myapp                # application name (prefixes networks, stacks, config/secret keys)
compose:
  version: 1              # docker compose CLI to use: 1 (docker-compose) or 2 (docker compose)
environments:             # list of environments (see below)
  - name: all
    # ...
  - name: staging
    # ...
```

### Environments

Each entry under `environments` has a `name` and any of the attributes below. The environment named
**`all`** holds global defaults that are merged into every other environment. The reserved names
`development`, `staging` and `production` are ordinary environments — `development` is only valid for
the `compose` target.

Most attributes are lists of entries carrying a `target:` selector, which is either a single target
(`compose`, `swarm`, `kubernetes`) or a list of them. The special value `all` matches every target.
For a given command, squarectl keeps the entries whose `target:` matches the current target, then
merges the global (`all` environment) values with the selected environment's values.

```yaml
environments:
  - name: all
    env_vars:                       # environment variables injected into the command
      - target: compose
        vars:
          TRAEFIK_DOMAIN: traefik.mydomain.local
      - target: [swarm, kubernetes]
        vars:
          MYAPP_RELEASE: "{{ ENV['MYAPP_RELEASE'] }}"

    compose_files:                  # extra compose files appended to the base ones
      - target: compose
        files: [monitoring.yml, debug.yml, networks.yml]

    networks:                       # external networks created before the stack starts
      - target: compose
        networks: [traefik-public]

  - name: staging
    domains:                        # `*_URL` vars; each derives `*_DOMAIN` and `*_SCHEME`
      - target: [compose, swarm]
        domains:
          BACK_OFFICE_URL: https://back.mydomain-staging.net

    ssl_certificates:               # certificates materialized before `up`
      - target: compose
        ssl_certificates:
          - domain: '*.mydomain-staging.net'
            cert_path: deploy/ssl/staging/wildcard.crt
            key_path: deploy/ssl/staging/wildcard.key

    setup_commands:                 # commands run by `setup`
      - target: all
        service: crono
        command: [bash, -l, -c, bin/rails db:setup]

    server:                         # remote Docker host used as DOCKER_HOST for swarm deploys
      - target: swarm
        host: ssh://deploy@swarm-staging

    config_files:                   # Docker Swarm configs, namespaced as <app>-<envshort>__<key>
      MYAPP_CONFIGS: deploy/swarm/staging/config.sh

    secret_files:                   # Docker Swarm secrets, namespaced as <app>-<envshort>__<key>
      MYAPP_SECRETS: deploy/swarm/staging/myapp.sh
```

squarectl also injects runtime variables into every command: `SQUARECTL_CWD`, `SQUARECTL_APP`,
`SQUARECTL_TARGET`, `SQUARECTL_ENV` and `SQUARECTL_ENV_SHORT`.

### Directory conventions

Paths are relative to the current working directory:

- `squarectl/base.yml` — base compose file, always prepended to the resolved compose file list.
- `squarectl/targets/<target>/{common,<env>}.yml` — per-target compose files, appended after the base.
- `squarectl/targets/common/` — files shared across targets.
- `kubernetes/<env>/` — Kubernetes manifests used by `kube deploy`.

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
