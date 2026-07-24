require "../../spec_helper.cr"

Spectator.describe Squarectl::Commands::Kompose do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  mock Squarectl::Executor

  let(executor) { mock(Squarectl::Executor) }
  let(environment_object) { Squarectl.find_environment(environment: "staging", target: "kubernetes") }
  let(task) { Squarectl::TaskFactory.build("kubernetes", environment_object, Squarectl.environment_all, executor) }

  describe "#run_kompose_convert" do
    it "does not leave the rendered compose tempfile behind" do
      pattern = File.join(Dir.tempdir, "*docker-compose*")
      before = Dir[pattern].to_set

      allow(executor).to receive(:run_command).and_return(true)
      task.run_kompose_convert("services: {}", [] of String)

      leftovers = Dir[pattern].to_set - before
      expect(leftovers).to be_empty
    end
  end
end
