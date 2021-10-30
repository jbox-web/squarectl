require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Secrets do
  double :task do
    stub create_docker_secrets(args)
    stub destroy_docker_secrets(args)
  end

  let(args) { [] of String }

  describe ".create" do
    it "calls docker secrets create command" do
      task = double(:task)
      expect(task).to receive(:create_docker_secrets).with(args)
      described_class.create(task, args)
    end
  end

  describe ".destroy" do
    it "calls docker secrets destroy command" do
      task = double(:task)
      expect(task).to receive(:destroy_docker_secrets).with(args)
      described_class.destroy(task, args)
    end
  end
end
