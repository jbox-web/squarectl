require "../../spec_helper.cr"

Spectator.describe Squarectl::TaskFactory do
  before_each { ENV["MYAPP_RELEASE"] = "1.0.0" }
  after_each { ENV.delete("MYAPP_RELEASE") }
  after_each { Squarectl.reset_config! }

  let(environment_object) { Squarectl.find_environment(environment: environment, target: target) }
  let(task) { Squarectl::TaskFactory.build(target, environment_object, Squarectl.environment_all) }

  context "with complex config" do
    before_each { Squarectl.load_config(config_file) }

    let(config_file) { "spec/fixtures/config/complex.yml" }

    context "when target is compose" do
      let(target) { "compose" }

      context "when environment is development" do
        let(environment) { "development" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end
    end

    context "when target is swarm" do
      let(target) { "swarm" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end
    end

    context "when target is kubernetes" do
      let(target) { "kubernetes" }

      context "when environment is staging" do
        let(environment) { "staging" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end

      context "when environment is production" do
        let(environment) { "production" }

        it "returns a built Task object" do
          expect(task).to be_a(Squarectl::Task)
          expect(task.squarectl_environment.to_yaml).to eq(File.read("spec/fixtures/tasks/complex/#{target}/#{environment}.yml"))
        end
      end
    end
  end
end
