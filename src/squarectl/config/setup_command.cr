module Squarectl
  module Config
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
