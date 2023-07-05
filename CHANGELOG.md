# CHANGELOG

## 1.5.1 (2023/07/05)

* build: bump to Crystal 1.8.2
* feat: add compose cp subcommand
* fix: remove short version of config flag because if conflicts with bash -l -c

## 1.5.0 (2023/04/19)

* build: bump to Crystal 1.8.0
* ci: fix github warning
* fix: rescue on unknown command/subcommand and display help

## 1.4.2 (2023/04/09)

* fix: add missing subcommand binding
* fix: add missing subcommand completion

## 1.4.1 (2023/04/09)

* build: bump to Crystal 1.7.3
* feat: add `squarectl compose push` subcommand
* build: bump to earthly 0.7.2
* ci: fix Github Actions warnings

## 1.4.0 (2022/10/13)

* build: bump to Crystal 1.7.2
* fix: kompose no longer interpolate env vars

## 1.3.0 (2022/10/13)

* build: bump to Crystal 1.6.0

## 1.2.1 (2022/05/20)

* feat: add docker-compose start command
* feat: add docker-compose stop command

## 1.2.0 (2022/05/20)

* build: bump to Crystal 1.4.1
* build: only publish a static binary on releases
* feat: add docker-compose exec command

## 1.1.0 (2021/11/06)

* add tests (a lot of tests)
* fix config overrides
* render config file with Crinja to allow users to inject env vars
* add support for Docker Compose v2

## 1.0.0 (2021/10/25)

First release!
