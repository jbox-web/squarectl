require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Configs do
  context "with fake task object" do
    double :task do
      stub create_docker_configs(args)
      stub destroy_docker_configs(args)
    end

    let(args) { [] of String }

    describe ".create" do
      it "calls docker configs create command" do
        task = double(:task)
        expect(task).to receive(:create_docker_configs).with(args)
        described_class.create(task, args)
      end
    end

    describe ".destroy" do
      it "calls docker configs destroy command" do
        task = double(:task)
        expect(task).to receive(:destroy_docker_configs).with(args)
        described_class.destroy(task, args)
      end
    end
  end
end
