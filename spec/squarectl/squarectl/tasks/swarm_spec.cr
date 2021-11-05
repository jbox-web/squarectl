require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Swarm do
  context "with fake task object" do
    double :task do
      stub run_docker_stack_deploy
      stub run_docker_stack_destroy
      stub run_swarm_setup_commands
    end

    let(args) { [] of String }

    describe ".deploy" do
      it "calls docker stack deploy" do
        task = double(:task)
        expect(task).to receive(:run_docker_stack_deploy)
        described_class.deploy(task, args)
      end
    end

    describe ".destroy" do
      it "calls docker stack destroy" do
        task = double(:task)
        expect(task).to receive(:run_docker_stack_destroy)
        described_class.destroy(task, args)
      end
    end

    describe ".setup" do
      it "calls custom setup command" do
        task = double(:task)
        expect(task).to receive(:run_swarm_setup_commands)
        described_class.setup(task, args)
      end
    end
  end

  context "with real task object" do
    before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

    mock Squarectl::Executor do
      stub run_command(cmd : String, args : Array(String), env : Hash(String, String)) { true }
      stub capture_output(cmd : String, args : Array(String), env : Hash(String, String)) { "12345" }
    end

    let(output) { IO::Memory.new }
    let(error) { IO::Memory.new }

    let(executor) { Squarectl::Executor.new(output: output, error: error) }

    let(environment_object) { Squarectl.find_environment(environment: "staging", target: "swarm") }
    let(task) { Squarectl::TaskFactory.build("swarm", environment_object, Squarectl.environment_all, executor) }

    let(root_dir) { Squarectl.root_dir }

    let(task_args) { [] of String }

    describe ".deploy" do
      it "calls docker (swarm) command" do
        args = [
          "stack",
          "deploy",
          "--compose-file",
          "#{root_dir}/squarectl/base.yml",
          "--compose-file",
          "#{root_dir}/squarectl/targets/swarm/common.yml",
          "--compose-file",
          "#{root_dir}/squarectl/targets/swarm/staging.yml",
          "--compose-file",
          "#{root_dir}/squarectl/targets/common/networks.yml",
          "--prune",
          "--with-registry-auth",
          "--resolve-image",
          "always",
          "myapp_staging",
        ]

        expect(executor).to receive(:run_command).with("docker", args, task.task_env_vars.merge({"DOCKER_HOST" => "ssh://deploy@swarm-staging"})).and_return(true)

        # call the method
        described_class.deploy(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end

    describe ".destroy" do
      it "calls docker (swarm) command" do
        args = ["stack", "rm", "myapp_staging"]
        expect(executor).to receive(:run_command).with("docker", args, {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}).and_return(true)

        # call the method
        described_class.destroy(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end

    describe ".setup" do
      it "calls docker (swarm) command" do
        expect(executor).to receive(:capture_output).with("docker", ["ps", "--filter", "name=crono", "--format", "{{.ID}}"], {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}).and_return("12345")
        expect(executor).to receive(:run_command).with("docker", ["exec", "12345", "bash", "-l", "-c", "bin/rails myapp:db:setup"], {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}).and_return(true)

        # call the method
        described_class.setup(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end
  end
end
