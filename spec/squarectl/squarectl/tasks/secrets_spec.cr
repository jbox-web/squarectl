require "../../../spec_helper.cr"

Spectator.describe Squarectl::Tasks::Secrets do
  context "with fake task object" do
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

  context "with real task object" do
    before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

    mock Squarectl::Executor do
      stub run_command(cmd : String, args : Array(String), env : Hash(String, String)) { true }
      stub run_command(cmd : String, args : Array(String), env : Hash(String, String), input : File) { true }
    end

    let(output) { IO::Memory.new }
    let(error) { IO::Memory.new }

    let(executor) { Squarectl::Executor.new(output: output, error: error) }

    let(environment_object) { Squarectl.find_environment(environment: "staging", target: "swarm") }
    let(task) { Squarectl::TaskFactory.build("swarm", environment_object, Squarectl.environment_all, executor) }

    let(task_args) { [] of String }

    describe ".create" do
      it "calls docker secret create command" do
        # set expectation on the cmd line
        expect(executor).to receive(:run_command).with("docker", ["secret", "create", "myapp-stag__MYAPP_SECRETS", "-"], {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}, File.open("spec/fixtures/deploy/swarm/staging/myapp.sh")).and_return(true)
        expect(executor).to receive(:run_command).with("docker", ["secret", "create", "myapp-stag__POSTGRES_PASSWORD", "-"], {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}, File.open("spec/fixtures/deploy/swarm/staging/postgres_password.sh")).and_return(true)

        # call the method
        described_class.create(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end

    describe ".destroy" do
      it "calls docker secret rm command" do
        # set expectation on the cmd line
        expect(executor).to receive(:run_command).with("docker", ["secret", "rm", "myapp-stag__MYAPP_SECRETS"], {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}).and_return(true)
        expect(executor).to receive(:run_command).with("docker", ["secret", "rm", "myapp-stag__POSTGRES_PASSWORD"], {"DOCKER_HOST" => "ssh://deploy@swarm-staging"}).and_return(true)

        # call the method
        described_class.destroy(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end
  end
end
