require "../../spec_helper.cr"

# `compose up` creates the environment's declared external networks before
# handing off to `docker compose`. `docker network create` exits non-zero when
# the network already exists, which must NOT abort the whole command — but any
# other creation failure still has to surface.
Spectator.describe Squarectl::Commands::Networks do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  mock Squarectl::Executor

  let(executor) { mock(Squarectl::Executor) }

  let(environment_object) { Squarectl.find_environment(environment: "staging", target: "compose") }
  let(task) { Squarectl::TaskFactory.build("compose", environment_object, Squarectl.environment_all, executor) }

  describe "#create_docker_networks" do
    it "creates each declared network" do
      expect(executor).to receive(:run_command).with("docker", ["network", "create", "traefik-public"]).and_return(true)

      task.create_docker_networks
    end

    it "tolerates a network that already exists" do
      allow(executor).to receive(:run_command).and_raise(Squarectl::CommandError.new("boom"))
      # The network is present after the failed create, so the failure was benign.
      allow(executor).to receive(:capture_output).with("docker", ["network", "inspect", "traefik-public"]).and_return(%([{"Name":"traefik-public"}]))

      expect { task.create_docker_networks }.to_not raise_error
    end

    it "re-raises when creation fails for another reason" do
      allow(executor).to receive(:run_command).and_raise(Squarectl::CommandError.new("boom"))
      # The network is still absent, so the failure was not "already exists".
      allow(executor).to receive(:capture_output).with("docker", ["network", "inspect", "traefik-public"]).and_return(nil)

      expect { task.create_docker_networks }.to raise_error(Squarectl::CommandError)
    end
  end
end
