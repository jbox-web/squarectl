require "../../spec_helper.cr"

module TestHelper
  def test_global_env_vars
    expect(task).to be_a(Squarectl::Task)
    expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq(
      {
        "#{target.upcase}_ALL_ONLY"                   => "true",
        "ALL_TARGETS"                                 => "true",
        "#{target.upcase}_#{environment.upcase}_ONLY" => "true",
        "#{environment.upcase}_ONLY_ALL_TARGETS"      => "true",
      }
    )
  end

  def test_global_networks
    expect(task).to be_a(Squarectl::Task)
    expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq [
      "#{target}_all_only",
      "all_targets",
      "#{target}_#{environment}_only",
      "#{environment}_only_all_targets",
    ]
  end

  def test_global_compose_files
    expect(task).to be_a(Squarectl::Task)
    expect(task.squarectl_environment["SQUARECTL_FILES"]).to eq [
      "#{root_dir}/squarectl/base.yml",
      "#{root_dir}/squarectl/targets/#{target}/common.yml",
      "#{root_dir}/squarectl/targets/#{target}/#{environment}.yml",
      "#{root_dir}/squarectl/targets/common/#{target}_all_only.yml",
      "#{root_dir}/squarectl/targets/common/all_targets.yml",
      "#{root_dir}/squarectl/targets/common/#{target}_#{environment}_only.yml",
      "#{root_dir}/squarectl/targets/common/#{environment}_only_all_targets.yml",
    ]
  end

  def test_global_setup_commands
    expect(task).to be_a(Squarectl::Task)
    expect(task.squarectl_environment["SQUARECTL_SETUP_COMMANDS"]).to eq [
      {"service" => "#{target}_all_only", "command" => ["foo"]},
      {"service" => "all_targets", "command" => ["foo"]},
      {"service" => "#{target}_#{environment}_only", "command" => ["foo"]},
      {"service" => "#{environment}_only_all_targets", "command" => ["foo"]},
    ]
  end

  def test_global_ssl_certificates
    expect(task).to be_a(Squarectl::Task)
    expect(task.squarectl_environment["SQUARECTL_SSL_CERTIFICATES"]).to eq [
      {"domain" => "#{target}_all_env.local", "cert_path" => "#{root_dir}/deploy/ssl/#{target}/all_env.crt", "key_path" => "#{root_dir}/deploy/ssl/#{target}/all_env.key"},
      {"domain" => "all_env_all_targets.local", "cert_path" => "#{root_dir}/deploy/ssl/all_env_all_targets.crt", "key_path" => "#{root_dir}/deploy/ssl/all_env_all_targets.key"},
      {"domain" => "#{target}_#{environment}_only.local", "cert_path" => "#{root_dir}/deploy/ssl/#{target}/#{environment}_only.crt", "key_path" => "#{root_dir}/deploy/ssl/#{target}/#{environment}_only.key"},
      {"domain" => "#{environment}_only_all_targets.local", "cert_path" => "#{root_dir}/deploy/ssl/#{environment}/all_targets.crt", "key_path" => "#{root_dir}/deploy/ssl/#{environment}/all_targets.key"},
    ]
  end
end

Spectator.describe Squarectl::TaskFactory do
  include TestHelper

  before_each { ENV["MYAPP_RELEASE"] = "1.0.0" }
  after_each { ENV.delete("MYAPP_RELEASE") }
  after_each { Squarectl.reset_config! }
  let(root_dir) { Squarectl.root_dir }

  let(environment_object) { Squarectl.find_environment(environment: environment, target: target) }
  let(task) { Squarectl::TaskFactory.build(target, environment_object, Squarectl.environment_all) }

  def render_crinja(str)
    Crinja.render(str, {"current_dir" => Dir.current}) + "\n"
  end

  context "with complex config" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/complex.yml" }
    let(fixture_file) { File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml") }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq render_crinja(fixture_file)
        end
      end
    end
  end

  context "with global env vars" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/with_global_env_vars.yml" }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" { test_global_env_vars }
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_env_vars }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_env_vars }
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_env_vars }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_env_vars }
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_env_vars }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_env_vars }
      end
    end
  end

  context "with global networks" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/with_global_networks.yml" }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" { test_global_networks }
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_networks }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_networks }
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_networks }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_networks }
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_networks }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_networks }
      end
    end
  end

  context "with global compose files" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/with_global_compose_files.yml" }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" { test_global_compose_files }
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_compose_files }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_compose_files }
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_compose_files }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_compose_files }
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_compose_files }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_compose_files }
      end
    end
  end

  context "with global setup commands" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/with_global_setup_commands.yml" }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" { test_global_setup_commands }
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_setup_commands }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_setup_commands }
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_setup_commands }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_setup_commands }
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_setup_commands }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_setup_commands }
      end
    end
  end

  context "with global ssl certificates" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/with_global_ssl_certificates.yml" }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" { test_global_ssl_certificates }
      end
    end
  end
end
