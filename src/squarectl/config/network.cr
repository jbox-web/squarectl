module Squarectl
  module Config
    # :nodoc:
    class Network
      include JSON::Serializable
      include YAML::Serializable

      property target : String = "compose"
      property networks : Array(String) = [] of String
    end
  end
end
