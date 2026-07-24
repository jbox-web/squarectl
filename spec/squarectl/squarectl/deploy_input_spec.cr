require "../../spec_helper.cr"

# Verifies that `docker config/secret create` is fed the right source file via
# stdin. Spectator has no argument matcher for "any File", so instead of a mock
# `.with(..., File)` (the limitation the configs/secrets specs noted) a fake
# executor records the path of each piped file.
class InputCapturingExecutor < Squarectl::Executor
  getter piped = [] of String

  def run_command(cmd : String, args : Array(String), env : Hash(String, String), input : File)
    @piped << input.path
    true
  end
end

Spectator.describe "Docker config/secret stdin piping" do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  let(executor) { InputCapturingExecutor.new }
  let(environment_object) { Squarectl.find_environment(environment: "staging", target: "swarm") }
  let(task) { Squarectl::TaskFactory.build("swarm", environment_object, Squarectl.environment_all, executor) }

  it "pipes each config source file into docker config create" do
    task.create_docker_configs([] of String)
    expect(executor.piped.any?(&.ends_with?("deploy/swarm/staging/config.sh"))).to be_true
  end

  it "pipes each secret source file into docker secret create" do
    task.create_docker_secrets([] of String)
    expect(executor.piped.any?(&.ends_with?("deploy/swarm/staging/myapp.sh"))).to be_true
    expect(executor.piped.any?(&.ends_with?("deploy/swarm/staging/postgres_password.sh"))).to be_true
  end
end
