require "../../spec_helper.cr"

Spectator.describe Squarectl::ShellCompletion do
  describe ".get" do
    it "serves the baked bash completion script" do
      script = Squarectl::ShellCompletion.get("bash.sh").gets_to_end

      expect(script.includes?("_squarectl_completion")).to be_true
      expect(script.includes?("complete -F _squarectl_completion squarectl")).to be_true
    end
  end
end
