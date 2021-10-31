require "../../spec_helper.cr"

Spectator.describe Squarectl::Executor do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  mock Squarectl::Executor do
    stub run_command(cmd, args)
    stub exec_command(cmd, args)

    stub run_command(cmd, args, env)
    stub exec_command(cmd, args, env)
  end

  let(environment) { "staging" }
  let(environment_object) { Squarectl.find_environment(environment: environment, target: target) }

  let(executor) { Squarectl::Executor.new }

  let(task) { Squarectl::TaskFactory.build(target, environment_object, Squarectl.environment_all, executor) }

  let(root_dir) { Squarectl.root_dir }

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

  context "with docker compose task" do
    let(target) { "compose" }
    let(task_class) { Squarectl::Tasks::Compose }

    describe "Squarectl::Tasks::Compose.config" do
      it "calls docker-compose command" do
        args = common_args + ["config"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { task_class.config(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe "Squarectl::Tasks::Compose.build" do
      it "calls docker-compose command" do
        args = common_args + ["build", "--pull"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { task_class.build(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe "Squarectl::Tasks::Compose.push" do
      it "calls docker-compose command" do
        args = common_args + ["push"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { task_class.push(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe "Squarectl::Tasks::Compose.down" do
      it "calls docker-compose command" do
        args = common_args + ["down"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { task_class.down(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe "Squarectl::Tasks::Compose.top" do
      it "calls docker-compose command" do
        args = common_args + ["top"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { task_class.top(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe "Squarectl::Tasks::Compose.ps" do
      it "calls docker-compose command" do
        args = common_args + ["ps"]

        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)
        expect { task_class.ps(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end

    describe "Squarectl::Tasks::Compose.clean" do
      it "calls docker-compose command" do
        args = common_args + ["down", "--rmi", "all", "-v"]

        expect(executor).to receive(:run_command).with("docker-compose", args, task.task_env_vars).and_return(true)
        expect(executor).to receive(:run_command).with("docker", ["network", "rm", "traefik-public"]).and_return(true)

        task_class.clean(task, [] of String)
      end
    end

    describe "Squarectl::Tasks::Compose.up" do
      it "calls docker-compose command" do
        args = common_args + ["up", "--remove-orphans"]

        expect(executor).to receive(:run_command).with("docker", ["network", "create", "traefik-public"]).and_return(true)
        expect(executor).to receive(:exec_command).with("docker-compose", args, task.task_env_vars).and_raise(Spectator::SystemExit)

        expect { task_class.up(task, [] of String) }.to raise_error(Spectator::SystemExit)
      end
    end
  end
end
