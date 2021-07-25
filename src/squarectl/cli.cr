module Squarectl
  # :nodoc:
  class CLI < Admiral::Command
    define_version Squarectl.version
    define_help description: "Squarectl is Salt PillarStack in Crystal"

    register_sub_command compose, Compose, description: "Show Squarectl information"
    register_sub_command swarm, Swarm, description: "Run Squarectl webserver"
    register_sub_command configs, Configs, description: "Run Squarectl webserver"
    register_sub_command secrets, Secrets, description: "Fetch host pillars"
    register_sub_command info, Info, description: "Fetch host pillars"
    register_sub_command kube, Kube, description: "Fetch host pillars"
    register_sub_command completion, Completion, description: "Fetch host pillars"

    def run
      puts help
    end
  end
end
