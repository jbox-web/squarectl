module Squarectl
  class CLI < Admiral::Command
    class Swarm < Admiral::Command
      SQUARECTL_TARGET = "swarm"

      class Config < Admiral::Command
        define_help description: "Run docker-compose config"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.config(task, arguments.rest)
        end
      end

      class Build < Admiral::Command
        define_help description: "Run docker-compose build"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.build(task, arguments.rest)
        end
      end

      class Push < Admiral::Command
        define_help description: "Run docker-compose push"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.push(task, arguments.rest)
        end
      end

      class Clean < Admiral::Command
        define_help description: "Run docker-compose clean"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.clean(task, arguments.rest)
        end
      end

      class Deploy < Admiral::Command
        define_help description: "Run docker stack deploy"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Swarm.deploy(task, arguments.rest)
        end
      end

      class Setup < Admiral::Command
        define_help description: "Run docker-compose setup"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Swarm.setup(task, arguments.rest)
        end
      end

      class Destroy < Admiral::Command
        define_help description: "Run docker stack rm"

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
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Swarm.destroy(task, arguments.rest)
        end
      end

      define_help description: "Run Docker Swarm commands"

      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command config, Config, description: "Run docker-compose config"
      register_sub_command build, Build, description: "Run docker-compose build"
      register_sub_command push, Push, description: "Run docker-compose push"
      register_sub_command clean, Clean, description: "Run docker-compose clean"
      register_sub_command deploy, Deploy, description: "Run docker stack deploy"
      register_sub_command setup, Setup, description: "Run docker stack deploy"
      register_sub_command destroy, Destroy, description: "Run docker stack rm"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
