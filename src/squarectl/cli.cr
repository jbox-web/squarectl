module Squarectl
  # :nodoc:
  class CLI < Admiral::Command
    define_version Squarectl.version
    define_help description: "Squarectl is Salt PillarStack in Crystal"

    register_sub_command compose, Compose, description: "Run Docker Compose commands"
    register_sub_command swarm, Swarm, description: "Run Docker Swarm commands"
    register_sub_command configs, Configs, description: "Manage Docker Swarm Configs"
    register_sub_command secrets, Secrets, description: "Manage Docker Swarm Secrets"
    register_sub_command info, Info, description: "Get Squarectl info"
    register_sub_command kube, Kube, description: "Run Kubernetes commands"
    register_sub_command completion, Completion, description: "Install shell completion"

    def run
      puts help
    end
  end
end
