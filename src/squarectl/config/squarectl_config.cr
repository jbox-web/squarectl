module Squarectl
  module Config
    # :nodoc:
    class SquarectlConfig
      include JSON::Serializable
      include YAML::Serializable

      property app : String = "example"
      property compose : Hash(String, Int32) = {"version" => 1}
      property environments : Array(SquarectlEnvironment) = [] of SquarectlEnvironment
    end
  end
end
