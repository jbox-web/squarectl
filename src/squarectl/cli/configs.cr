module Squarectl
  class CLI < Admiral::Command
    class Configs < Admiral::Command
      SQUARECTL_TARGET = "swarm"

      leaf_command Create, "Create Docker Swarm Configs", SQUARECTL_TARGET, Squarectl::Tasks::Configs.create(task, arguments.rest)
      leaf_command Destroy, "Destroy Docker Swarm Configs", SQUARECTL_TARGET, Squarectl::Tasks::Configs.destroy(task, arguments.rest)

      define_help description: "Manage Docker Swarm Configs"

      # ameba:disable Lint/UselessAssign
      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command create, Create, description: "Create Docker Swarm Configs"
      register_sub_command destroy, Destroy, description: "Destroy Docker Swarm Configs"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
