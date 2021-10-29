require "../../spec_helper.cr"

Spectator.describe Squarectl::TaskFactory do
  before_each { ENV["MYAPP_RELEASE"] = "1.0.0" }
  after_each { ENV.delete("MYAPP_RELEASE") }
  after_each { Squarectl.reset_config! }

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

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"COMPOSE_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "COMPOSE_DEVELOPMENT_ONLY" => "true", "DEVELOPMENT_ONLY_ALL_TARGETS" => "true"})
        end
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"COMPOSE_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "COMPOSE_STAGING_ONLY" => "true", "STAGING_ONLY_ALL_TARGETS" => "true"})
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"COMPOSE_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "COMPOSE_PRODUCTION_ONLY" => "true", "PRODUCTION_ONLY_ALL_TARGETS" => "true"})
        end
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"SWARM_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "SWARM_STAGING_ONLY" => "true", "STAGING_ONLY_ALL_TARGETS" => "true"})
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"SWARM_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "SWARM_PRODUCTION_ONLY" => "true", "PRODUCTION_ONLY_ALL_TARGETS" => "true"})
        end
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"KUBERNETES_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "KUBERNETES_STAGING_ONLY" => "true", "STAGING_ONLY_ALL_TARGETS" => "true"})
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_ENV_VARS"]).to eq({"KUBERNETES_ALL_ONLY" => "true", "ALL_TARGETS" => "true", "KUBERNETES_PRODUCTION_ONLY" => "true", "PRODUCTION_ONLY_ALL_TARGETS" => "true"})
        end
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

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["COMPOSE_ALL_ONLY", "ALL_TARGETS", "COMPOSE_DEVELOPMENT_ONLY", "DEVELOPMENT_ONLY_ALL_TARGETS"]
        end
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["COMPOSE_ALL_ONLY", "ALL_TARGETS", "COMPOSE_STAGING_ONLY", "STAGING_ONLY_ALL_TARGETS"]
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["COMPOSE_ALL_ONLY", "ALL_TARGETS", "COMPOSE_PRODUCTION_ONLY", "PRODUCTION_ONLY_ALL_TARGETS"]
        end
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["SWARM_ALL_ONLY", "ALL_TARGETS", "SWARM_STAGING_ONLY", "STAGING_ONLY_ALL_TARGETS"]
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["SWARM_ALL_ONLY", "ALL_TARGETS", "SWARM_PRODUCTION_ONLY", "PRODUCTION_ONLY_ALL_TARGETS"]
        end
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["KUBERNETES_ALL_ONLY", "ALL_TARGETS", "KUBERNETES_STAGING_ONLY", "STAGING_ONLY_ALL_TARGETS"]
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment["SQUARECTL_NETWORKS"]).to eq ["KUBERNETES_ALL_ONLY", "ALL_TARGETS", "KUBERNETES_PRODUCTION_ONLY", "PRODUCTION_ONLY_ALL_TARGETS"]
        end
      end
    end
  end
end
