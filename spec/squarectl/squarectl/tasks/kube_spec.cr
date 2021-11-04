require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Kube do
  context "with fake task object" do
    double :task do
      stub run_kubectl_apply
      stub run_kubectl_setup_commands
    end

    let(args) { [] of String }

    describe ".convert" do
      it "calls kompose convert command" do
        task = double(:task)
        expect(task).to receive(:run_kompose).with("convert", ["--out", "foo", "--with-kompose-annotation=false"])
        described_class.convert(task, args, "foo")
      end
    end

    describe ".apply" do
      it "calls kubectl apply command" do
        task = double(:task)
        expect(task).to receive(:run_kubectl_apply)
        described_class.apply(task, args)
      end
    end

    describe ".setup" do
      it "calls custom setup command" do
        task = double(:task)
        expect(task).to receive(:run_kubectl_setup_commands)
        described_class.setup(task, args)
      end
    end
  end
end
