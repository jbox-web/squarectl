module Squarectl
  module Config
    # :nodoc:
    class EnvVar
      include JSON::Serializable
      include YAML::Serializable

      property target : String = "compose"
      property vars : Hash(String, String) = {} of String => String
    end
  end
end
