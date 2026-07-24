require "../../spec_helper.cr"

Spectator.describe Squarectl do
  describe ".executor" do
    it "defaults to an Executor instance" do
      expect(Squarectl.executor).to be_a(Squarectl::Executor)
    end

    it "can be overridden (dependency injection for the CLI)" do
      custom = Squarectl::Executor.new
      Squarectl.executor = custom
      expect(Squarectl.executor).to be(custom)
    end

    it "is reset by reset_config! so a test executor does not leak" do
      custom = Squarectl::Executor.new
      Squarectl.executor = custom
      Squarectl.reset_config!
      expect(Squarectl.executor).to_not be(custom)
    end
  end
end
