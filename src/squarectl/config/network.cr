module Squarectl
  module Config
    # External Docker networks to create before `up` and remove on `clean`,
    # scoped to one or more targets.
    #
    # :nodoc:
    class Network
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property networks : Array(String) = [] of String
    end
  end
end
