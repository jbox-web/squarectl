module Squarectl
  module Config
    # :nodoc:
    class ComposeFile
      include JSON::Serializable
      include YAML::Serializable

      property target : String = "compose"
      property files : Array(String) = [] of String
    end
  end
end
