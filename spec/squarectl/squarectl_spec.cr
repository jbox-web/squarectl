require "../spec_helper.cr"

Spectator.describe Squarectl do
  after_each { Squarectl.reset_config! }

  let(squarectl_root_dir) { Path.new(Dir.current) }

  describe ".root_dir" do
    it "returns Squarectl root_dir" do
      expect(Squarectl.root_dir).to eq(squarectl_root_dir)
    end
  end

  describe ".kubernetes_dir" do
    it "returns Squarectl kubernetes_dir" do
      expect(Squarectl.kubernetes_dir).to eq(squarectl_root_dir.join("kubernetes"))
    end
  end

  describe ".data_dir" do
    it "returns Squarectl data_dir" do
      expect(Squarectl.data_dir).to eq(squarectl_root_dir.join("squarectl"))
    end
  end

  describe ".targets_dir" do
    it "returns Squarectl targets_dir" do
      expect(Squarectl.targets_dir).to eq(squarectl_root_dir.join("squarectl").join("targets"))
    end
  end

  describe ".targets_common_dir" do
    it "returns Squarectl targets_common_dir" do
      expect(Squarectl.targets_common_dir).to eq(squarectl_root_dir.join("squarectl").join("targets").join("common"))
    end
  end

  describe ".load_config" do
    context "with minimal config" do
      let(file) { "spec/fixtures/config/minimal.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.app_name).to eq("example")
        expect(Squarectl.environments).to eq([] of Squarectl::Config::SquarectlEnvironment)
        expect(Squarectl.environment_all).to eq(nil)
      end
    end

    context "with complex config" do
      let(file) { "spec/fixtures/config/complex.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.app_name).to eq("myapp")
        expect(Squarectl.environments).to be_a(Array(Squarectl::Config::SquarectlEnvironment))
        expect(Squarectl.environments.size).to eq(4)
        expect(Squarectl.environment_all).to_not be_nil
      end
    end
  end

  describe ".app_name" do
    context "with minimal config" do
      it "returns Squarectl app_name" do
        expect(Squarectl.app_name).to eq("example")
      end
    end

    context "with custom app name" do
      let(file) { "spec/fixtures/config/with_custom_app_name.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.app_name).to eq("foo")
        expect(Squarectl.environments).to eq([] of Squarectl::Config::SquarectlEnvironment)
        expect(Squarectl.environment_all).to eq(nil)
      end
    end
  end

  describe ".environments" do
    context "with minimal config" do
      it "returns a list of Squarectl environments" do
        expect(Squarectl.environments).to eq([] of Squarectl::Config::SquarectlEnvironment)
      end
    end

    context "with environments" do
      let(file) { "spec/fixtures/config/with_environments.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.environments).to be_a(Array(Squarectl::Config::SquarectlEnvironment))
        expect(Squarectl.environments.size).to eq(4)
        expect(Squarectl.environment_all).to_not be_nil
      end
    end
  end

  describe ".environment_all" do
    context "with minimal config" do
      it "returns the Squarectl 'all' environment" do
        expect(Squarectl.environment_all).to eq(nil)
      end
    end

    context "with environments" do
      let(file) { "spec/fixtures/config/with_environments.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.environments).to be_a(Array(Squarectl::Config::SquarectlEnvironment))
        expect(Squarectl.environments.size).to eq(4)
        expect(Squarectl.environment_all).to_not be_nil
      end
    end
  end

  describe ".find_environment" do
    context "with minimal config" do
      it "should raise an error when target is not found" do
        expect { Squarectl.find_environment(environment: "dev", target: "foo") }.to raise_error("Target not found: foo")
      end

      it "should not raise an error when target exist" do
        expect { Squarectl.find_environment(environment: "dev", target: "compose") }.to_not raise_error("Target not found: compose")
      end

      it "should raise an error when no environments are defined" do
        expect { Squarectl.find_environment(environment: "dev", target: "compose") }.to raise_error("Environment not found: dev")
      end
    end

    context "with environments" do
      let(file) { "spec/fixtures/config/with_environments.yml" }

      it "should not raise an error when target exist" do
        Squarectl.load_config(file)
        expect { Squarectl.find_environment(environment: "dev", target: "compose") }.to_not raise_error("Target not found: compose")
      end

      it "should not raise an error when environments are defined" do
        Squarectl.load_config(file)
        expect { Squarectl.find_environment(environment: "dev", target: "compose") }.to_not raise_error("Environment not found: dev")
      end

      it "should find environment by short name" do
        Squarectl.load_config(file)
        env = Squarectl.find_environment(environment: "dev", target: "compose")
        expect(env).to_not be_nil
        expect(env.name).to eq "development"
      end

      it "should find environment by full name" do
        Squarectl.load_config(file)
        env = Squarectl.find_environment(environment: "development", target: "compose")
        expect(env).to_not be_nil
        expect(env.name).to eq "development"
      end

      it "should find environment for all targets (compose, swarm, kubernetes)" do
        Squarectl.load_config(file)
        env = Squarectl.find_environment(environment: "development", target: "compose")
        expect(env).to_not be_nil
        expect(env.name).to eq "development"

        env = Squarectl.find_environment(environment: "stag", target: "swarm")
        expect(env).to_not be_nil
        expect(env.name).to eq "staging"

        env = Squarectl.find_environment(environment: "prod", target: "kubernetes")
        expect(env).to_not be_nil
        expect(env.name).to eq "production"
      end

      it "should raise an error if environment is development and target is not compose" do
        Squarectl.load_config(file)
        expect { Squarectl.find_environment(environment: "development", target: "swarm") }.to raise_error("You can't use this command in development environment")
        expect { Squarectl.find_environment(environment: "development", target: "kubernetes") }.to raise_error("You can't use this command in development environment")
      end
    end
  end
end
