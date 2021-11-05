require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Compose do
  context "with fake task object" do
    double :task do
      stub run_docker_compose(cmd, args)
      stub exec_docker_compose(cmd, args)
      stub create_ssl_certificates
      stub create_docker_networks
      stub run_docker_compose_setup_commands
    end

    let(args) { [] of String }

    describe ".config" do
      it "calls docker-compose config" do
        task = double(:task)
        expect(task).to receive(:exec_docker_compose).with("config", args)
        described_class.config(task, args)
      end
    end

    describe ".build" do
      it "calls docker-compose build" do
        task = double(:task)
        expect(task).to receive(:exec_docker_compose).with("build", ["--pull"])
        described_class.build(task, args)
      end
    end

    describe ".push" do
      it "calls docker-compose push" do
        task = double(:task)
        expect(task).to receive(:exec_docker_compose).with("push", args)
        described_class.push(task, args)
      end
    end

    describe ".clean" do
      it "calls composite docker-compose down" do
        task = double(:task)
        expect(task).to receive(:run_docker_compose).with("down", ["--rmi", "all", "-v"])
        expect(task).to receive(:destroy_docker_networks)
        expect(task).to receive(:destroy_ssl_certificates)
        described_class.clean(task, args)
      end
    end

    describe ".up" do
      it "calls composite docker-compose up" do
        task = double(:task)
        expect(task).to receive(:create_ssl_certificates)
        expect(task).to receive(:create_docker_networks)
        expect(task).to receive(:exec_docker_compose).with("up", ["--remove-orphans"])
        described_class.up(task, args)
      end
    end

    describe ".down" do
      it "calls docker-compose down" do
        task = double(:task)
        expect(task).to receive(:exec_docker_compose).with("down", args)
        described_class.down(task, args)
      end
    end

    describe ".top" do
      it "calls docker-compose top" do
        task = double(:task)
        expect(task).to receive(:exec_docker_compose).with("top", args)
        described_class.top(task, args)
      end
    end

    describe ".ps" do
      it "calls docker-compose ps" do
        task = double(:task)
        expect(task).to receive(:exec_docker_compose).with("ps", args)
        described_class.ps(task, args)
      end
    end

    describe ".setup" do
      it "calls custom setup command" do
        task = double(:task)
        expect(task).to receive(:run_docker_compose_setup_commands)
        described_class.setup(task, args)
      end
    end
  end

  context "with real task object" do
    before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

    mock Squarectl::Executor do
      stub run_command(cmd : String, args : Array(String)) { true }
      stub exec_command(cmd : String, args : Array(String))

      stub run_command(cmd : String, args : Array(String), env : Hash(String, String)) { true }
      stub exec_command(cmd : String, args : Array(String), env : Hash(String, String))
    end

    let(output) { IO::Memory.new }
    let(error) { IO::Memory.new }

    let(executor) { Squarectl::Executor.new(output: output, error: error) }

    let(environment_object) { Squarectl.find_environment(environment: "staging", target: "compose") }
    let(task) { Squarectl::TaskFactory.build("compose", environment_object, Squarectl.environment_all, executor) }

    let(root_dir) { Squarectl.root_dir }

    let(task_args) { [] of String }

    let(common_args) {
      [
        "--project-name",
        "myapp_staging",
        "--file",
        "#{root_dir}/squarectl/base.yml",
        "--file",
        "#{root_dir}/squarectl/targets/compose/common.yml",
        "--file",
        "#{root_dir}/squarectl/targets/compose/staging.yml",
        "--file",
        "#{root_dir}/squarectl/targets/common/monitoring.yml",
        "--file",
        "#{root_dir}/squarectl/targets/common/debug.yml",
        "--file",
        "#{root_dir}/squarectl/targets/common/networks.yml",
      ]
    }

    describe ".config" do
      it "calls docker-compose command" do
        args = common_args + ["config"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { described_class.config(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".build" do
      it "calls docker-compose command" do
        args = common_args + ["build", "--pull"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { described_class.build(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".push" do
      it "calls docker-compose command" do
        args = common_args + ["push"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { described_class.push(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".clean" do
      it "calls docker-compose command" do
        args = common_args + ["down", "--rmi", "all", "-v"]

        expect(executor).to receive(:run_command).with("docker-compose", args, task.task_env_vars).and_return(true)
        expect(executor).to receive(:run_command).with("docker", ["network", "rm", "traefik-public"]).and_return(true)

        described_class.clean(task, task_args)
      end
    end

    describe ".up" do
      it "calls docker-compose command" do
        args = common_args + ["up", "--remove-orphans"]

        expect(executor).to receive(:run_command).with("docker", ["network", "create", "traefik-public"]).and_return(true)
        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)

        expect { described_class.up(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".down" do
      it "calls docker-compose command" do
        args = common_args + ["down"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { described_class.down(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".top" do
      it "calls docker-compose command" do
        args = common_args + ["top"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { described_class.top(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".ps" do
      it "calls docker-compose command" do
        args = common_args + ["ps"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { described_class.ps(task, task_args) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe ".setup" do
      it "calls docker-compose command" do
        # set expectation on the cmd line
        args = common_args + ["exec", "-T", "crono", "bash", "-l", "-c", "bin/rails myapp:db:setup"]

        expect(executor).to receive(:run_command).with("docker-compose", args, task.task_env_vars).and_return(true)

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
