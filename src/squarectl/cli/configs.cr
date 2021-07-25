module Squarectl
  class CLI < Admiral::Command
    class Configs < Admiral::Command
      SQUARECTL_TARGET = "swarm"

      class Create < Admiral::Command
        define_help description: "Create Docker Swarm Configs"

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
          Squarectl::Tasks::Configs.create(task, arguments.rest)
        end
      end

      class Destroy < Admiral::Command
        define_help description: "Destroy Docker Swarm Configs"

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
          Squarectl::Tasks::Configs.destroy(task, arguments.rest)
        end
      end

      define_help description: "Manage Docker Swarm Configs"

      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command create, Create, description: "Create Docker Swarm Configs"
      register_sub_command destroy, Destroy, description: "Destroy Docker Swarm Configs"

      def run
        puts help
      end
    end
  end
end
