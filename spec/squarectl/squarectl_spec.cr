require "../spec_helper.cr"

Spectator.describe Squarectl do
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
    after_each { Squarectl.reset_config! }

    context "with minimal config" do
      let(file) { "spec/fixtures/config/minimal.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.app_name).to eq("example")
        expect(Squarectl.environments).to eq([] of Squarectl::Config::SquarectlEnvironment)
        expect(Squarectl.environment_all).to eq(nil)
      end
    end

    context "with custom app name" do
      let(file) { "spec/fixtures/config/custom_app_name.yml" }

      it "should load yaml config file" do
        Squarectl.load_config(file)

        expect(Squarectl.app_name).to eq("foo")
        expect(Squarectl.environments).to eq([] of Squarectl::Config::SquarectlEnvironment)
        expect(Squarectl.environment_all).to eq(nil)
      end
    end
  end

  context "with minimal config" do
    describe ".app_name" do
      it "returns Squarectl app_name" do
        expect(Squarectl.app_name).to eq("example")
      end
    end

    describe ".environments" do
      it "returns a list of Squarectl environments" do
        expect(Squarectl.environments).to eq([] of Squarectl::Config::SquarectlEnvironment)
      end
    end

    describe ".environment_all" do
      it "returns the Squarectl 'all' environment" do
        expect(Squarectl.environment_all).to eq(nil)
      end
    end

    describe ".find_environment" do
      it "should raise an error when target is not found" do
        expect { Squarectl.find_environment(environment: "dev", target: "foo") }.to raise_error("Target not found: foo")
      end

      it "should raise an error when no environments are defined" do
        expect { Squarectl.find_environment(environment: "dev", target: "compose") }.to raise_error("Environment not found: dev")
      end
    end
  end
end
