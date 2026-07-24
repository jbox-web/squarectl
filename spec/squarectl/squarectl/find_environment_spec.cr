require "../../spec_helper.cr"

Spectator.describe Squarectl do
  describe ".find_environment" do
    context "with ambiguous environment names" do
      before_each { Squarectl.load_config("spec/fixtures/config/with_ambiguous_environments.yml") }

      it "raises when the name matches more than one environment" do
        expect { Squarectl.find_environment(environment: "staging", target: "compose") }
          .to raise_error(/[Aa]mbiguous/)
      end

      it "prefers an exact match over a longer environment that contains it" do
        env = Squarectl.find_environment(environment: "prod", target: "compose")
        expect(env.name).to eq("prod")
      end
    end
  end
end
