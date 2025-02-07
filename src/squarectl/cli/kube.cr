module Squarectl
  class CLI < Admiral::Command
    class Kube < Admiral::Command
      SQUARECTL_TARGET = "kubernetes"

      class Config < Admiral::Command
        define_help description: "Run docker-compose config"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.config(task, arguments.rest)
        end
      end

      class Build < Admiral::Command
        define_help description: "Run docker-compose build"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.build(task, arguments.rest)
        end
      end

      class Push < Admiral::Command
        define_help description: "Run docker-compose push"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.push(task, arguments.rest)
        end
      end

      class Clean < Admiral::Command
        define_help description: "Run docker-compose clean"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.clean(task, arguments.rest)
        end
      end

      class Deploy < Admiral::Command
        define_help description: "Deploy Kubernetes configuration"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Kube.apply(task, arguments.rest)
        end
      end

      class Setup < Admiral::Command
        define_help description: "Run kubectl exec"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          short: "c",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Kube.setup(task, arguments.rest)
        end
      end

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
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
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
      register_sub_command deploy, Deploy, description: "Deploy Docker Swarm Secrets"
      register_sub_command setup, Setup, description: "Deploy Docker Swarm Secrets"
      register_sub_command convert, Convert, description: "Convert Docker Swarm Secrets"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
