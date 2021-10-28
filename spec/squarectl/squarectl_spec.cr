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
end
