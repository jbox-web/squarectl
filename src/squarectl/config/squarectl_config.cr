module Squarectl
  module Config
    # Root of the parsed `squarectl.yml`: the app name, the Compose version
    # (`1` selects the legacy `docker-compose` binary), and the environments.
    #
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
