module Squarectl
  module Config
    # :nodoc:
    class SquarectlConfig
      include JSON::Serializable
      include YAML::Serializable

      property app : String = "example"
      property environments : Array(SquarectlEnvironment)
    end
  end
end
