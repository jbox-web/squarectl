module Squarectl
  class CLI < Admiral::Command
    class Info < Admiral::Command
      leaf_command Compose, "Get Squarectl configuration info about Compose target", "compose", Squarectl::Tasks::Info.compose(task, arguments.rest)
      leaf_command Swarm, "Get Squarectl configuration info about Swarm target", "swarm", Squarectl::Tasks::Info.swarm(task, arguments.rest)
      leaf_command Kubernetes, "Get Squarectl configuration info about Kubernetes target", "kubernetes", Squarectl::Tasks::Info.kubernetes(task, arguments.rest)

      define_help description: "Get Squarectl info"

      # ameba:disable Lint/UselessAssign
      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command compose, Compose, description: "Get Squarectl configuration info about Compose target"
      register_sub_command swarm, Swarm, description: "Get Squarectl configuration info about Swarm target"
      register_sub_command kube, Kubernetes, description: "Get Squarectl configuration info about Kubernetes target"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
