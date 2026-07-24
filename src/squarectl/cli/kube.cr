module Squarectl
  class CLI < Admiral::Command
    class Kube < Admiral::Command
      SQUARECTL_TARGET = "kubernetes"

      leaf_command Config, "Run docker-compose config", SQUARECTL_TARGET, Squarectl::Tasks::Compose.config(task, arguments.rest)
      leaf_command Build, "Run docker-compose build", SQUARECTL_TARGET, Squarectl::Tasks::Compose.build(task, arguments.rest)
      leaf_command Push, "Run docker-compose push", SQUARECTL_TARGET, Squarectl::Tasks::Compose.push(task, arguments.rest)
      leaf_command Clean, "Run docker-compose clean", SQUARECTL_TARGET, Squarectl::Tasks::Compose.clean(task, arguments.rest)
      leaf_command Deploy, "Deploy Kubernetes configuration", SQUARECTL_TARGET, Squarectl::Tasks::Kube.apply(task, arguments.rest)
      leaf_command Setup, "Run kubectl exec", SQUARECTL_TARGET, Squarectl::Tasks::Kube.setup(task, arguments.rest)

      # `convert` keeps a bespoke definition: it takes an extra `--output` flag and
      # forwards it to the conversion.
      class Convert < Admiral::Command
        define_help description: "Convert Docker Compose configuration to Kubernetes"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_flag output : String,
          description: "Specify a file name or directory to save objects to (if path does not exist, a file will be created)",
          long: "output",
          short: "o",
          default: ""

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all, Squarectl.executor)
          Squarectl::Tasks::Kube.convert(task, arguments.rest, flags.output)
        end
      end

      define_help description: "Manage Kubernetes configuration"

      # ameba:disable Lint/UselessAssign
      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command config, Config, description: "Run docker-compose config"
      register_sub_command build, Build, description: "Run docker-compose build"
      register_sub_command push, Push, description: "Run docker-compose push"
      register_sub_command clean, Clean, description: "Run docker-compose clean"
      register_sub_command deploy, Deploy, description: "Deploy Kubernetes configuration"
      register_sub_command setup, Setup, description: "Run kubectl exec setup commands"
      register_sub_command convert, Convert, description: "Convert Docker Compose configuration to Kubernetes"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
