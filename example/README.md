# squarectl example — the `blog` app

A minimal, self-contained squarectl project for a fictional `blog` application
(a `web` service backed by `postgres`). It shows the layout and the core
mechanics — layered compose files, the global `all` environment, `target:`
selectors, `_URL` domain derivation, and Swarm configs/secrets — without the
noise of a real deployment.

Run every command from this directory (squarectl resolves paths relative to the
current working directory).

## Layout

```
example/
├── squarectl.yml                     # the config: app + all/development/production
├── squarectl/
│   ├── base.yml                      # base compose (web + postgres), always prepended
│   └── targets/
│       ├── common/traefik.yml        # shared external traefik-public network
│       ├── compose/
│       │   ├── common.yml            # traefik labels (uses BLOG_DOMAIN)
│       │   └── development.yml       # local overlay (source mount, exposed port)
│       └── swarm/
│           ├── common.yml            # deploy: replicas / restart policy
│           └── production.yml        # scale the web tier up
└── deploy/swarm/production/
    ├── config                        # → docker config create (content piped verbatim)
    └── postgres_password             # → docker secret create (content piped verbatim)
```

For a given command squarectl assembles the compose file list in this order:
`base.yml`, then `targets/<target>/common.yml`, then `targets/<target>/<env>.yml`,
then any files declared under `compose_files` (looked up in `targets/common/`).

## Try it

```sh
# Inspect the fully resolved configuration without running anything:
squarectl info compose development
squarectl info swarm production

# Print the merged docker compose config:
squarectl compose config development

# Bring the stack up locally (creates the SSL certs + traefik-public network first):
squarectl compose up development

# Tear it down (also removes the networks + certificates):
squarectl compose clean development
```

`compose up` generates the `development` SSL certificates automatically with
[mkcert](https://github.com/FiloSottile/mkcert) (writing them to
`deploy/ssl/development/wildcard.local.{crt,key}` and running `mkcert -install`), skips any that
already exist, and removes them again on `compose clean` — so you only need `mkcert` on your PATH.

Swarm deploys target the host declared under `server:` (`ssh://deploy@swarm-prod`
in this example) — adjust it to a reachable Docker host before running
`squarectl swarm deploy production`.

## Notes

- `BLOG_URL` in `domains` automatically derives `BLOG_DOMAIN` and `BLOG_SCHEME`,
  consumed by the Traefik labels in `targets/compose/common.yml`.
- `config_files` / `secret_files` values point at files whose **entire content**
  is piped into `docker config create` / `docker secret create`; the keys are
  namespaced as `<app>-<envshort>__<key>` (e.g. `blog-prod__POSTGRES_PASSWORD`).
- Set `SQUARECTL_DEBUG=true` to print the full command line and environment
  before each command runs.
