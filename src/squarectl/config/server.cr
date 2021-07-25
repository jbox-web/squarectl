module Squarectl
  module Config
    # :nodoc:
    class Server
      include JSON::Serializable
      include YAML::Serializable

      property target : String = "swarm"
      property host : String = "ssh://localhost"
    end
  end
end
