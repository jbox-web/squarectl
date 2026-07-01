module Squarectl
  module Config
    # A command run inside a service during `setup` (via `compose exec`,
    # `docker exec` on swarm, or `kubectl exec`), scoped to one or more targets.
    #
    # :nodoc:
    class SetupCommand
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property service : String
      property command : Array(String) = [] of String

      def to_h
        {
          "service" => service,
          "command" => command,
        }
      end
    end
  end
end
