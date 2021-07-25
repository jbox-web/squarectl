module Squarectl
  module Config
    # :nodoc:
    class Domain
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property domains : Hash(String, String) = {} of String => String
    end
  end
end
