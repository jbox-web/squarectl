require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Swarm do
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
