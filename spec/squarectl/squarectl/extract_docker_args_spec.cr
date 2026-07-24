require "../../spec_helper.cr"

# Characterization tests for the pre-/post-action argument splitting used when
# assembling a `docker compose` command line. This logic had no coverage.
Spectator.describe Squarectl::Commands::Compose do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  let(environment_object) { Squarectl.find_environment(environment: "staging", target: "compose") }
  let(task) { Squarectl::TaskFactory.build("compose", environment_object, Squarectl.environment_all) }

  describe "#extract_docker_args" do
    it "returns two empty lists for no arguments" do
      expect(task.extract_docker_args([] of String)).to eq({[] of String, [] of String})
    end

    it "routes a boolean global flag before the action" do
      expect(task.extract_docker_args(["--dry-run"])).to eq({["--dry-run"], [] of String})
    end

    it "routes a valued global flag and consumes its value" do
      expect(task.extract_docker_args(["--profile", "web"])).to eq({["--profile", "web"], [] of String})
    end

    it "routes the --flag=value form of a global flag before the action" do
      expect(task.extract_docker_args(["--profile=web"])).to eq({["--profile=web"], [] of String})
    end

    it "leaves unknown arguments after the action" do
      expect(task.extract_docker_args(["--detach", "svc"])).to eq({[] of String, ["--detach", "svc"]})
    end

    it "splits a mix of pre- and post-action arguments" do
      expect(task.extract_docker_args(["--profile", "web", "up", "--detach"]))
        .to eq({["--profile", "web"], ["up", "--detach"]})
    end
  end
end
