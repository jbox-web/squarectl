module Squarectl
  class CLI < Admiral::Command
    class Secrets < Admiral::Command
      SQUARECTL_TARGET = "swarm"

      class Create < Admiral::Command
        define_help description: "Create Docker Swarm Secrets"

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
          Squarectl::Tasks::Secrets.create(task, arguments.rest)
        end
      end

      class Destroy < Admiral::Command
        define_help description: "Destroy Docker Swarm Secrets"

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
          Squarectl::Tasks::Secrets.destroy(task, arguments.rest)
        end
      end

      define_help description: "Manage Docker Swarm Secrets"

      # ameba:disable Lint/UselessAssign
      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command create, Create, description: "Create Docker Swarm Secrets"
      register_sub_command destroy, Destroy, description: "Destroy Docker Swarm Secrets"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
