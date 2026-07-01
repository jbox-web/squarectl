module Squarectl
  module Config
    # The remote Docker host used as `DOCKER_HOST` for swarm deploys (e.g.
    # `ssh://user@host`).
    #
    # :nodoc:
    class Server
      include JSON::Serializable
      include YAML::Serializable

      property target : String = "swarm"
      property host : String = "ssh://localhost"
    end
  end
end
