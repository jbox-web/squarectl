module Squarectl
  module Config
    # Extra compose files (resolved under `squarectl/targets/common/`) to append
    # after the conventional base files, scoped to one or more targets.
    #
    # :nodoc:
    class ComposeFile
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property files : Array(String) = [] of String
    end
  end
end
