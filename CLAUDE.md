# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`squarectl` is a Crystal CLI that wraps `docker compose`, `docker swarm` (configs/secrets),
and `kubectl`/`kompose`. It reads a single YAML config (`squarectl.yml` by default) describing
one or more **environments** (development, staging, production, ...) and renders the right
env vars, compose file lists, networks, SSL certs, and deploy artifacts before shelling out to
the underlying tool. The user picks a **target** (`compose`, `swarm`, `kubernetes`) and an
**environment**; squarectl assembles the command and `exec`s it.

## Toolchain & commands

The dev environment is managed by [mise](https://mise.jdx.dev) (`mise.toml`), which pins
Crystal and defines all tasks. Run tasks with `mise <task>`:

- `mise dev:deps` — `shards install`
- `mise dev:build` — compile a dev binary to `bin/squarectl`
- `mise dev:spec` — run the test suite (`crystal spec`)
- `mise dev:ameba` — static analysis (`ameba`, a mise tool), bounded at 180s
- `mise dev:format` — `crystal tool format src/ spec/`
- `mise dev:licenses` — assemble `licenses/` from `licenses.manifest` (every compiling task depends on it)
- `mise dev:coverage` — spec line coverage with kcov, into `coverage/`
- `mise dev:docker-image` — local multi-arch image (`docker-bake.hcl`, target `docker-image`)
- `mise release:build` — a local `--release` binary of the host platform, plus its `.sha256` (outside the release path)
- `mise release:static` — the release, rehearsed by crystalreleaser into `dist/`, nothing published

Run a single spec file / example (mise forwards the arguments; never bare `crystal spec`, which
skips the pinned toolchain and the `dev:licenses` dependency):
```sh
mise dev:spec spec/squarectl/squarectl/task_factory_spec.cr
mise dev:spec spec/squarectl/squarectl/task_factory_spec.cr:42   # by line
```

Releases: crystalreleaser (`.crystalreleaser.yml`: the canonical template without `static_libs`,
squarectl links no OpenSSL, plus the apk packages of libxml2 and xz) builds the binaries,
`mise release:static` locally and `.github/workflows/release.yml` on a `v*` tag, which publishes
`squarectl-<os>-<arch>` and its `.sha256`. The `Dockerfile` builds only the Docker Hub image
(`release_dockerhub.yml`).

Licenses: `licenses.manifest` follows the link line of the static binary (recorded in its
header); `scripts/harvest-licenses.sh` assembles the gitignored `licenses/`, which
`src/squarectl/licenses.cr` embeds and `squarectl licenses` prints. Compiling without it fails on
purpose.

Tests use **spectator** (not Crystal's built-in spec DSL) — see `spec/spec_helper.cr`.
`Spectator.reset` calls `Squarectl.reset_config!` after each example because config is held in
class-level state on the `Squarectl` module (`@@config`, `@@environments`). Any test that loads
config relies on that reset.

Note: on macOS, `mise dev:fix-shards-command` is a required workaround for a Crystal packaging
bug (crystal-lang/crystal#16746) before `shards` works — CI runs it before installing deps.

## Request flow (the important architecture)

Understanding one command path explains all of them — every subcommand follows the same 4-layer
pipeline. Example: `squarectl compose up staging`.

1. **`src/squarectl/cli/*.cr`** — Admiral command tree. `CLI` (`cli.cr`) registers top-level
   subcommands (`compose`, `swarm`, `configs`, `secrets`, `kube`, `info`, `completion`; plus
   `licenses`, which only prints the embedded notices), each of
   which registers its own leaf commands. Every leaf `run` does the same three steps:
   `Squarectl.load_config(flags.config)` → `Squarectl.find_environment(env, TARGET)` →
   `TaskFactory.build(...)` → hand off to a `Tasks::*` class. The `SQUARECTL_TARGET` constant on
   each command class ("compose"/"swarm"/"kubernetes") is what selects the target.

2. **`src/squarectl/task_factory.cr`** — the merge engine. Builds a `Task` by combining the
   selected environment with the special `"all"` environment (global defaults). Env vars, domains,
   compose files, networks, SSL certs, setup commands, configs, and secrets are each resolved by
   selecting entries whose `target:` matches (via `find_matching_target`, which honors `"all"`)
   and merging global-then-env. Heavy use of macros (`define_method_hash` / `define_method_array`)
   generates the per-attribute resolvers. Also derives `_DOMAIN`/`_SCHEME` vars from any `_URL`
   var (`decompose_urls`) and namespaces config/secret keys as `<app>-<envshort>__<key>`.

3. **`src/squarectl/tasks/*.cr`** — thin orchestration per target. Class methods like
   `Tasks::Compose.up` decide the sequence of side effects (e.g. `up` creates SSL certs + networks
   first, then execs; `clean` tears them down). These call methods mixed into `Task`.

4. **`src/squarectl/commands/*.cr`** — the actual command builders, mixed into `Task` (see the
   `include` list in `task.cr`). `build_docker_compose_command` assembles argv, splits user args
   into pre-args (before the action) vs post-args via the `PRE_ARGS_*` allowlists in
   `commands/compose.cr`, and handles compose v1 (`docker-compose`) vs v2 (`docker compose`).
   Everything ultimately runs through **`Executor`** (`executor.cr`): `run_command` (wait),
   `exec_command` (replace process), or `capture_output`. Set `SQUARECTL_DEBUG=true` to print the
   full command line + env instead of guessing what ran.

## Config model & conventions

- `src/squarectl/config/*.cr` are `YAML::Serializable` structs mapping the `squarectl.yml` schema
  (`SquarectlConfig` → `app`, `compose.version`, `environments[]`; each `SquarectlEnvironment` has
  `server`, `env_vars`, `networks`, `compose_files`, `domains`, `ssl_certificates`,
  `setup_commands`, `config_files`, `secret_files`).
- Config is a **Crinja (Jinja) template** rendered with `ENV` before parsing — `Squarectl.load_config`
  runs `Crinja.render` first, so `{{ ENV.FOO }}` works in `squarectl.yml`.
- Directory conventions relative to the project (`Squarectl.root_dir` = cwd):
  `squarectl/base.yml`, `squarectl/targets/<target>/{common,<env>}.yml`,
  `squarectl/targets/common/`, and `kubernetes/<env>/`. These base compose files are always
  prepended to the resolved compose file list (see `compose_file_*_for` in `squarectl_environment.cr`).
- The environment named **`all`** is global defaults merged into every other environment. An entry
  with `target: all` (or a target array) applies across targets.
- `development` environment is restricted to the `compose` target only (`find_environment` raises otherwise).
- Runtime vars injected into every task: `SQUARECTL_CWD/APP/TARGET/ENV/ENV_SHORT` (see `Task#runtime_env_vars`).

## Conventions

- `ameba:disable` inline comments are used deliberately (e.g. for `not_nil!` and Admiral's
  `Lint/UselessAssign` on flag definitions) — keep them when editing those lines.
- Commit messages follow Conventional Commits (`commitlint.config.js`): `feat:`, `fix:`, `build:`,
  `ci:`, etc.
- crystalline (the Crystal LSP, in `mise.toml [tools]`) is for editors only and is disabled in CI
  via `MISE_DISABLE_TOOLS` because its macOS binary needs Homebrew LLVM.
