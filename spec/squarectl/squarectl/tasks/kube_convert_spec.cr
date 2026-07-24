require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Kube do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  mock Squarectl::Executor

  let(executor) { mock(Squarectl::Executor) }
  let(environment_object) { Squarectl.find_environment(environment: "staging", target: "kubernetes") }
  let(task) { Squarectl::TaskFactory.build("kubernetes", environment_object, Squarectl.environment_all, executor) }

  describe ".convert" do
    context "when the compose configuration cannot be rendered" do
      it "raises and leaves the existing output directory untouched" do
        dir = File.tempname
        FileUtils.mkdir_p(dir)
        sentinel = File.join(dir, "keep.yaml")
        File.write(sentinel, "keep me")

        # docker compose config fails -> capture returns nil
        allow(executor).to receive(:capture_output).and_return(nil)
        # kompose must never be invoked when there is no configuration to convert
        allow(executor).to receive(:run_command).and_return(true)

        begin
          expect { Squarectl::Tasks::Kube.convert(task, [] of String, dir) }
            .to raise_error(Squarectl::CommandError)
          expect(File.exists?(sentinel)).to be_true
        ensure
          FileUtils.rm_rf(dir)
        end
      end
    end
  end
end
