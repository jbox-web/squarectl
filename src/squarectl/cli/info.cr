module Squarectl
  class CLI < Admiral::Command
    class Info < Admiral::Command
      class Compose < Admiral::Command
        define_help description: "Get Squarectl configuration info about Compose target"

        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, "compose")
          task = Squarectl::TaskFactory.build("compose", environment, Squarectl.environment_all)
          Squarectl::Tasks::Info.compose(task, arguments.rest)
        end
      end

      class Swarm < Admiral::Command
        define_help description: "Get Squarectl configuration info about Swarm target"

        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, "swarm")
          task = Squarectl::TaskFactory.build("swarm", environment, Squarectl.environment_all)
          Squarectl::Tasks::Info.swarm(task, arguments.rest)
        end
      end

      class Kubernetes < Admiral::Command
        define_help description: "Get Squarectl configuration info about Kubernetes target"

        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, "kubernetes")
          task = Squarectl::TaskFactory.build("kubernetes", environment, Squarectl.environment_all)
          Squarectl::Tasks::Info.kubernetes(task, arguments.rest)
        end
      end

      define_help description: "Get Squarectl info"

      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command compose, Compose, description: "Get Squarectl configuration info about Compose target"
      register_sub_command swarm, Swarm, description: "Get Squarectl configuration info about Swarm target"
      register_sub_command kube, Kubernetes, description: "Get Squarectl configuration info about Kubernetes target"

      def run
        puts help
      end
    end
  end
end
