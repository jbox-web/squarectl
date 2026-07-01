module Squarectl
  module Config
    # A set of environment variables scoped to one or more targets. Merged into
    # the child process environment (see `Task#task_env_vars`).
    #
    # :nodoc:
    class EnvVar
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property vars : Hash(String, String) = {} of String => String
    end
  end
end
