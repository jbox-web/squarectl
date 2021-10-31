require "../../spec_helper.cr"

Spectator.describe Squarectl::Task do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  let(environment_object) { Squarectl.find_environment(environment: "staging", target: target) }
  let(task) { Squarectl::TaskFactory.build(target, environment_object, Squarectl.environment_all) }
  let(root_dir) { Squarectl.root_dir.to_s }

  context "with docker compose task" do
    let(target) { "compose" }

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

  context "with docker swarm task" do
    let(target) { "swarm" }

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

  context "with kubernetes task" do
    let(target) { "kubernetes" }

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
end
