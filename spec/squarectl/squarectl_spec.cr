require "../spec_helper.cr"

def squarectl_root_dir
  Path.new(Dir.current)
end

describe Squarectl do
  describe ".root_dir" do
    it "returns Squarectl root_dir" do
      Squarectl.root_dir.should eq(squarectl_root_dir)
    end
  end

  describe ".data_dir" do
    it "returns Squarectl data_dir" do
      Squarectl.data_dir.should eq(squarectl_root_dir.join("squarectl"))
    end
  end

  describe ".targets_dir" do
    it "returns Squarectl targets_dir" do
      Squarectl.targets_dir.should eq(squarectl_root_dir.join("squarectl").join("targets"))
    end
  end

  describe ".targets_common_dir" do
    it "returns Squarectl targets_common_dir" do
      Squarectl.targets_common_dir.should eq(squarectl_root_dir.join("squarectl").join("targets").join("common"))
    end
  end
end
