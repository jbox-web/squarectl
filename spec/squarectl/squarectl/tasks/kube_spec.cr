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

  context "with real task object" do
    before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

    mock Squarectl::Executor do
      stub run_command(cmd : String, args : Array(String)) { true }
      stub capture_output(cmd : String, args : Array(String)) { "12345" }
      stub exec_command(cmd : String, args : Array(String))

      stub run_command(cmd : String, args : Array(String), env : Hash(String, String)) { true }
      stub exec_command(cmd : String, args : Array(String), env : Hash(String, String))
    end

    let(output) { IO::Memory.new }
    let(error) { IO::Memory.new }

    let(executor) { Squarectl::Executor.new(output: output, error: error) }

    let(environment_object) { Squarectl.find_environment(environment: "staging", target: "kubernetes") }
    let(task) { Squarectl::TaskFactory.build("kubernetes", environment_object, Squarectl.environment_all, executor) }

    let(root_dir) { Squarectl.root_dir }

    let(task_args) { [] of String }

    describe ".convert" do
      it "calls kompose command" do
        args = [
          "--file",
          "#{root_dir}/squarectl/base.yml",
          "--file",
          "#{root_dir}/squarectl/targets/kubernetes/common.yml",
          "--file",
          "#{root_dir}/squarectl/targets/kubernetes/staging.yml",
          "convert",
          "--out",
          "#{root_dir}/kubernetes/staging/",
          "--with-kompose-annotation=false",
        ]

        expect(executor).to receive(:run_command).with("kompose", args, task.task_env_vars).and_return(true)

        # call the method
        described_class.convert(task, task_args, "")

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end

    describe ".apply" do
      it "calls kubectl command" do
        expect(executor).to receive(:run_command).with("kubectl", ["apply", "-f", "#{root_dir}/kubernetes/staging"]).and_return(true)

        # call the method
        described_class.apply(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end

    describe ".setup" do
      it "calls kubectl command" do
        expect(executor).to receive(:capture_output).with("kubectl", ["get", "pods", "--selector=io.kompose.service=crono", "--output=custom-columns=NAME:.metadata.name", "--no-headers=true"]).and_return("12345")
        expect(executor).to receive(:run_command).with("kubectl", ["exec", "12345", "--", "bash", "-l", "-c", "bin/rails myapp:db:setup"]).and_return(true)

        # call the method
        described_class.setup(task, task_args)

        # be sure that stdout or stderr are empty
        # if not, it means that the mock has failed and the cmd
        # has been really executed and thus that something has changed.
        expect(output.to_s).to eq("")
        expect(error.to_s).to eq("")
      end
    end
  end
end
