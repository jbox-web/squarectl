require "../../spec_helper.cr"

Spectator.describe Squarectl::Task do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  let(environment_object) { Squarectl.find_environment(environment: environment, target: target) }
  let(task) { Squarectl::TaskFactory.build(target, environment_object, Squarectl.environment_all) }
  let(root_dir) { Squarectl.root_dir.to_s }

  context "with docker compose task" do
    let(target) { "compose" }

    context "when environment is development" do
      let(environment) { "development" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_development"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "compose",
              "SQUARECTL_ENV"       => "development",
              "SQUARECTL_ENV_SHORT" => "deve",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "compose",
              "SQUARECTL_ENV"       => "development",
              "SQUARECTL_ENV_SHORT" => "deve",
              "TRAEFIK_DOMAIN"      => "traefik.mydomain.local",
              "GRAFANA_DOMAIN"      => "grafana.mydomain.local",
              "PROMETHEUS_DOMAIN"   => "prometheus.mydomain.local",
              "BACK_OFFICE_URL"     => "https://back.mydomain.local",
              "STATIC_FILES_URL"    => "https://static.mydomain.local",
              "FRENCH_SITE_URL"     => "https://front-fr.mydomain.local",
              "SPANISH_SITE_URL"    => "https://front-es.mydomain.local",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain.local",
              "BACK_OFFICE_SCHEME"  => "https",
              "STATIC_FILES_DOMAIN" => "static.mydomain.local",
              "STATIC_FILES_SCHEME" => "https",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain.local",
              "FRENCH_SITE_SCHEME"  => "https",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain.local",
              "SPANISH_SITE_SCHEME" => "https",
            }
          )
        end
      end

      describe "#build_docker_compose_command" do
        context "when docker compose version is not specified" do
          before_each { Squarectl.load_config("spec/fixtures/config/with_docker_compose_v1_default.yml") }

          let(tuple) {
            {
              cmd:  "docker-compose",
              args: [
                "--project-name",
                "example_development",
                "--file",
                "#{root_dir}/squarectl/base.yml",
                "--file",
                "#{root_dir}/squarectl/targets/compose/common.yml",
                "--file",
                "#{root_dir}/squarectl/targets/compose/development.yml",
                "build",
              ],
            }
          }

          it "returns a {cmd, args} tuple for docker compose v1" do
            expect(task.build_docker_compose_command("build", [] of String)).to eq(tuple)
          end
        end

        context "when docker compose version is v1" do
          before_each { Squarectl.load_config("spec/fixtures/config/with_docker_compose_v1.yml") }

          let(tuple) {
            {
              cmd:  "docker-compose",
              args: [
                "--project-name",
                "example_development",
                "--file",
                "#{root_dir}/squarectl/base.yml",
                "--file",
                "#{root_dir}/squarectl/targets/compose/common.yml",
                "--file",
                "#{root_dir}/squarectl/targets/compose/development.yml",
                "build",
              ],
            }
          }

          it "returns a {cmd, args} tuple for docker compose v1" do
            expect(task.build_docker_compose_command("build", [] of String)).to eq(tuple)
          end
        end

        context "when docker compose version is v2" do
          before_each { Squarectl.load_config("spec/fixtures/config/with_docker_compose_v2.yml") }

          let(tuple) {
            {
              cmd:  "docker",
              args: [
                "compose",
                "--project-name",
                "example_development",
                "--file",
                "#{root_dir}/squarectl/base.yml",
                "--file",
                "#{root_dir}/squarectl/targets/compose/common.yml",
                "--file",
                "#{root_dir}/squarectl/targets/compose/development.yml",
                "build",
              ],
            }
          }

          it "returns a {cmd, args} tuple for docker compose v2" do
            expect(task.build_docker_compose_command("build", [] of String)).to eq(tuple)
          end
        end
      end
    end

    context "when environment is staging" do
      let(environment) { "staging" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_staging"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "compose",
              "SQUARECTL_ENV"       => "staging",
              "SQUARECTL_ENV_SHORT" => "stag",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "compose",
              "SQUARECTL_ENV"       => "staging",
              "SQUARECTL_ENV_SHORT" => "stag",
              "TRAEFIK_DOMAIN"      => "traefik.mydomain.local",
              "GRAFANA_DOMAIN"      => "grafana.mydomain.local",
              "PROMETHEUS_DOMAIN"   => "prometheus.mydomain.local",
              "BACK_OFFICE_URL"     => "https://back.mydomain-staging.net",
              "STATIC_FILES_URL"    => "https://static.mydomain-staging.net",
              "FRENCH_SITE_URL"     => "https://front-fr.mydomain-staging.net",
              "SPANISH_SITE_URL"    => "https://front-es.mydomain-staging.net",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain-staging.net",
              "BACK_OFFICE_SCHEME"  => "https",
              "STATIC_FILES_DOMAIN" => "static.mydomain-staging.net",
              "STATIC_FILES_SCHEME" => "https",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain-staging.net",
              "FRENCH_SITE_SCHEME"  => "https",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain-staging.net",
              "SPANISH_SITE_SCHEME" => "https",
            }
          )
        end
      end
    end

    context "when environment is production" do
      let(environment) { "production" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_production"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "compose",
              "SQUARECTL_ENV"       => "production",
              "SQUARECTL_ENV_SHORT" => "prod",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "compose",
              "SQUARECTL_ENV"       => "production",
              "SQUARECTL_ENV_SHORT" => "prod",
              "TRAEFIK_DOMAIN"      => "traefik.mydomain.local",
              "GRAFANA_DOMAIN"      => "grafana.mydomain.local",
              "PROMETHEUS_DOMAIN"   => "prometheus.mydomain.local",
              "BACK_OFFICE_URL"     => "https://back.mydomain-production.net",
              "STATIC_FILES_URL"    => "https://static.mydomain-production.net",
              "FRENCH_SITE_URL"     => "https://front-fr.mydomain-production.net",
              "SPANISH_SITE_URL"    => "https://front-es.mydomain-production.net",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain-production.net",
              "BACK_OFFICE_SCHEME"  => "https",
              "STATIC_FILES_DOMAIN" => "static.mydomain-production.net",
              "STATIC_FILES_SCHEME" => "https",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain-production.net",
              "FRENCH_SITE_SCHEME"  => "https",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain-production.net",
              "SPANISH_SITE_SCHEME" => "https",
            }
          )
        end
      end
    end
  end

  context "with docker swarm task" do
    let(target) { "swarm" }

    context "when environment is staging" do
      let(environment) { "staging" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_staging"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "swarm",
              "SQUARECTL_ENV"       => "staging",
              "SQUARECTL_ENV_SHORT" => "stag",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "swarm",
              "SQUARECTL_ENV"       => "staging",
              "SQUARECTL_ENV_SHORT" => "stag",
              "MYAPP_RELEASE"       => "",
              "BACK_OFFICE_URL"     => "https://back.mydomain-staging.net",
              "STATIC_FILES_URL"    => "https://static.mydomain-staging.net",
              "FRENCH_SITE_URL"     => "https://front-fr.mydomain-staging.net",
              "SPANISH_SITE_URL"    => "https://front-es.mydomain-staging.net",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain-staging.net",
              "BACK_OFFICE_SCHEME"  => "https",
              "STATIC_FILES_DOMAIN" => "static.mydomain-staging.net",
              "STATIC_FILES_SCHEME" => "https",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain-staging.net",
              "FRENCH_SITE_SCHEME"  => "https",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain-staging.net",
              "SPANISH_SITE_SCHEME" => "https",
            }
          )
        end
      end
    end

    context "when environment is production" do
      let(environment) { "production" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_production"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "swarm",
              "SQUARECTL_ENV"       => "production",
              "SQUARECTL_ENV_SHORT" => "prod",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "swarm",
              "SQUARECTL_ENV"       => "production",
              "SQUARECTL_ENV_SHORT" => "prod",
              "MYAPP_RELEASE"       => "",
              "BACK_OFFICE_URL"     => "https://back.mydomain-production.net",
              "STATIC_FILES_URL"    => "https://static.mydomain-production.net",
              "FRENCH_SITE_URL"     => "https://front-fr.mydomain-production.net",
              "SPANISH_SITE_URL"    => "https://front-es.mydomain-production.net",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain-production.net",
              "BACK_OFFICE_SCHEME"  => "https",
              "STATIC_FILES_DOMAIN" => "static.mydomain-production.net",
              "STATIC_FILES_SCHEME" => "https",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain-production.net",
              "FRENCH_SITE_SCHEME"  => "https",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain-production.net",
              "SPANISH_SITE_SCHEME" => "https",
            }
          )
        end
      end
    end
  end

  context "with kubernetes task" do
    let(target) { "kubernetes" }

    context "when environment is staging" do
      let(environment) { "staging" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_staging"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "kubernetes",
              "SQUARECTL_ENV"       => "staging",
              "SQUARECTL_ENV_SHORT" => "stag",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "kubernetes",
              "SQUARECTL_ENV"       => "staging",
              "SQUARECTL_ENV_SHORT" => "stag",
              "MYAPP_RELEASE"       => "",
              "BACK_OFFICE_URL"     => "http://back.mydomain-staging.net",
              "STATIC_FILES_URL"    => "http://static.mydomain-staging.net",
              "FRENCH_SITE_URL"     => "http://front-fr.mydomain-staging.net",
              "SPANISH_SITE_URL"    => "http://front-es.mydomain-staging.net",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain-staging.net",
              "BACK_OFFICE_SCHEME"  => "http",
              "STATIC_FILES_DOMAIN" => "static.mydomain-staging.net",
              "STATIC_FILES_SCHEME" => "http",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain-staging.net",
              "FRENCH_SITE_SCHEME"  => "http",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain-staging.net",
              "SPANISH_SITE_SCHEME" => "http",
            }
          )
        end
      end
    end

    context "when environment is production" do
      let(environment) { "production" }

      describe "#project_name" do
        it "returns project_name" do
          expect(task.project_name).to eq "myapp_production"
        end
      end

      describe "#runtime_env_vars" do
        it "returns runtime_env_vars" do
          expect(task.runtime_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "kubernetes",
              "SQUARECTL_ENV"       => "production",
              "SQUARECTL_ENV_SHORT" => "prod",
            }
          )
        end
      end

      describe "#task_env_vars" do
        it "returns task_env_vars" do
          expect(task.task_env_vars).to eq(
            {
              "SQUARECTL_CWD"       => root_dir,
              "SQUARECTL_APP"       => "myapp",
              "SQUARECTL_TARGET"    => "kubernetes",
              "SQUARECTL_ENV"       => "production",
              "SQUARECTL_ENV_SHORT" => "prod",
              "MYAPP_RELEASE"       => "",
              "BACK_OFFICE_URL"     => "http://back.mydomain-production.net",
              "STATIC_FILES_URL"    => "http://static.mydomain-production.net",
              "FRENCH_SITE_URL"     => "http://front-fr.mydomain-production.net",
              "SPANISH_SITE_URL"    => "http://front-es.mydomain-production.net",
              "BACK_OFFICE_DOMAIN"  => "back.mydomain-production.net",
              "BACK_OFFICE_SCHEME"  => "http",
              "STATIC_FILES_DOMAIN" => "static.mydomain-production.net",
              "STATIC_FILES_SCHEME" => "http",
              "FRENCH_SITE_DOMAIN"  => "front-fr.mydomain-production.net",
              "FRENCH_SITE_SCHEME"  => "http",
              "SPANISH_SITE_DOMAIN" => "front-es.mydomain-production.net",
              "SPANISH_SITE_SCHEME" => "http",
            }
          )
        end
      end
    end
  end
end
