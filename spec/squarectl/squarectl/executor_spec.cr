require "../../spec_helper.cr"

Spectator.describe Squarectl::Executor do
  let(executor) { Squarectl::Executor.new(IO::Memory.new, IO::Memory.new) }

  describe "#capture_output" do
    it "returns nil when the command succeeds but produces no output" do
      expect(executor.capture_output("true", [] of String)).to be_nil
    end

    it "passes arguments to the command as real argv and returns its output" do
      expect(executor.capture_output("printf", ["squarectl"])).to eq("squarectl")
    end
  end

  describe "#run_command" do
    it "raises when the command exits non-zero" do
      expect { executor.run_command("false", [] of String) }.to raise_error(Squarectl::CommandError)
    end

    it "does not raise when the command succeeds" do
      expect { executor.run_command("true", [] of String) }.to_not raise_error
    end
  end
end
