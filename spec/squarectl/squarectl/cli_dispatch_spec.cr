require "../../spec_helper.cr"

# Characterization tests for the CLI dispatch layer (previously untested): they
# lock which underlying command each `squarectl <target> <verb> <env>` invocation
# runs, so the upcoming macro refactor of `cli/` cannot silently remap a verb to
# the wrong Tasks method. A RecordingExecutor is injected through the
# `Squarectl.executor` seam; it records every spawned command instead of shelling
# out (and raises on exec_command, which normally replaces the process).
class RecordingExecutor < Squarectl::Executor
  class ExecStop < Exception; end

  getter commands = [] of String

  private def record(cmd, args)
    @commands << "#{cmd} #{args.join(" ")}"
  end

  def run_command(cmd : String, args : Array(String))
    record(cmd, args)
    true
  end

  def run_command(cmd : String, args : Array(String), env : Hash(String, String))
    record(cmd, args)
    true
  end

  def run_command(cmd : String, args : Array(String), env : Hash(String, String), input : File)
    record(cmd, args)
    true
  end

  def capture_output(cmd : String, args : Array(String))
    record(cmd, args)
    "recorded-output"
  end

  def capture_output(cmd : String, args : Array(String), env : Hash(String, String))
    record(cmd, args)
    "recorded-id"
  end

  def exec_command(cmd : String, args : Array(String), env : Hash(String, String)) : NoReturn
    record(cmd, args)
    raise ExecStop.new
  end
end

CONFIG = "spec/fixtures/config/complex.yml"

Spectator.describe Squarectl::CLI do
  let(rec) { RecordingExecutor.new }
  before_each { Squarectl.executor = rec }

  # Runs a CLI invocation, swallowing the ExecStop that exec_command raises.
  def run_cli(argv)
    Squarectl::CLI.run(argv)
  rescue RecordingExecutor::ExecStop
    # exec_command was reached: dispatch happened, process would have been replaced
  end

  describe "compose target" do
    it "config -> docker-compose config" do
      run_cli(["compose", "config", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" config"))).to be_true
    end

    it "build -> docker-compose build --pull" do
      run_cli(["compose", "build", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("build --pull"))).to be_true
    end

    it "push -> docker-compose push" do
      run_cli(["compose", "push", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" push"))).to be_true
    end

    it "up -> docker-compose up --remove-orphans" do
      run_cli(["compose", "up", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("up --remove-orphans"))).to be_true
    end

    it "down -> docker-compose down" do
      run_cli(["compose", "down", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" down"))).to be_true
    end

    it "top -> docker-compose top" do
      run_cli(["compose", "top", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" top"))).to be_true
    end

    it "ps -> docker-compose ps" do
      run_cli(["compose", "ps", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" ps"))).to be_true
    end

    it "setup -> docker-compose exec -T <service>" do
      run_cli(["compose", "setup", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("exec -T crono"))).to be_true
    end

    it "clean -> docker-compose down --rmi all -v" do
      run_cli(["compose", "clean", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("down --rmi all -v"))).to be_true
    end

    it "exec -> docker-compose exec" do
      run_cli(["compose", "exec", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.ends_with?(" exec"))).to be_true
    end

    it "cp -> docker-compose cp" do
      run_cli(["compose", "cp", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.ends_with?(" cp"))).to be_true
    end

    it "start -> docker-compose start" do
      run_cli(["compose", "start", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.ends_with?(" start"))).to be_true
    end

    it "stop -> docker-compose stop" do
      run_cli(["compose", "stop", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.ends_with?(" stop"))).to be_true
    end
  end

  describe "swarm target" do
    it "config -> docker-compose config" do
      run_cli(["swarm", "config", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" config"))).to be_true
    end

    it "build -> docker-compose build --pull" do
      run_cli(["swarm", "build", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("build --pull"))).to be_true
    end

    it "push -> docker-compose push" do
      run_cli(["swarm", "push", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" push"))).to be_true
    end

    it "clean -> docker-compose down --rmi all -v" do
      run_cli(["swarm", "clean", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("down --rmi all -v"))).to be_true
    end

    it "deploy -> docker stack deploy" do
      run_cli(["swarm", "deploy", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("stack deploy"))).to be_true
    end

    it "setup -> docker exec <container>" do
      run_cli(["swarm", "setup", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("exec recorded-id"))).to be_true
    end

    it "destroy -> docker stack rm" do
      run_cli(["swarm", "destroy", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("stack rm"))).to be_true
    end
  end

  describe "kubernetes target" do
    it "config -> docker-compose config" do
      run_cli(["kube", "config", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" config"))).to be_true
    end

    it "build -> docker-compose build --pull" do
      run_cli(["kube", "build", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("build --pull"))).to be_true
    end

    it "push -> docker-compose push" do
      run_cli(["kube", "push", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?(" push"))).to be_true
    end

    it "clean -> docker-compose down --rmi all -v" do
      run_cli(["kube", "clean", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("down --rmi all -v"))).to be_true
    end

    it "deploy -> kubectl apply -f" do
      run_cli(["kube", "deploy", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("apply -f"))).to be_true
    end

    it "setup -> kubectl exec <pod>" do
      run_cli(["kube", "setup", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("exec recorded-output"))).to be_true
    end

    it "convert -> kompose convert" do
      out = File.join(Dir.tempdir, "squarectl-dispatch-out")
      run_cli(["kube", "convert", "--config", CONFIG, "--output", out, "staging"])
      expect(rec.commands.any?(&.includes?("convert"))).to be_true
    end
  end

  describe "configs" do
    it "create -> docker config create" do
      run_cli(["configs", "create", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("config create"))).to be_true
    end

    it "destroy -> docker config rm" do
      run_cli(["configs", "destroy", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("config rm"))).to be_true
    end
  end

  describe "secrets" do
    it "create -> docker secret create" do
      run_cli(["secrets", "create", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("secret create"))).to be_true
    end

    it "destroy -> docker secret rm" do
      run_cli(["secrets", "destroy", "--config", CONFIG, "staging"])
      expect(rec.commands.any?(&.includes?("secret rm"))).to be_true
    end
  end

  # info is read-only (prints YAML, never shells out); characterize that each
  # target dispatches without error and without touching the executor.
  describe "info" do
    it "compose dispatches without error or executor call" do
      expect { run_cli(["info", "compose", "--config", CONFIG, "staging"]) }.to_not raise_error
      expect(rec.commands).to be_empty
    end

    it "swarm dispatches without error or executor call" do
      expect { run_cli(["info", "swarm", "--config", CONFIG, "staging"]) }.to_not raise_error
      expect(rec.commands).to be_empty
    end

    it "kube dispatches without error or executor call" do
      expect { run_cli(["info", "kube", "--config", CONFIG, "staging"]) }.to_not raise_error
      expect(rec.commands).to be_empty
    end
  end
end
