module Squarectl
  class CLI < Admiral::Command
    class Secrets < Admiral::Command
      SQUARECTL_TARGET = "swarm"

      leaf_command Create, "Create Docker Swarm Secrets", SQUARECTL_TARGET, Squarectl::Tasks::Secrets.create(task, arguments.rest)
      leaf_command Destroy, "Destroy Docker Swarm Secrets", SQUARECTL_TARGET, Squarectl::Tasks::Secrets.destroy(task, arguments.rest)

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
