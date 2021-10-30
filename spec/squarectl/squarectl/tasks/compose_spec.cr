require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Compose do
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
