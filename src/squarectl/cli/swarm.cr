module Squarectl
  class CLI < Admiral::Command
    class Swarm < Admiral::Command
      SQUARECTL_TARGET = "swarm"

      leaf_command Config, "Run docker-compose config", SQUARECTL_TARGET, Squarectl::Tasks::Compose.config(task, arguments.rest)
      leaf_command Build, "Run docker-compose build", SQUARECTL_TARGET, Squarectl::Tasks::Compose.build(task, arguments.rest)
      leaf_command Push, "Run docker-compose push", SQUARECTL_TARGET, Squarectl::Tasks::Compose.push(task, arguments.rest)
      leaf_command Clean, "Run docker-compose clean", SQUARECTL_TARGET, Squarectl::Tasks::Compose.clean(task, arguments.rest)
      leaf_command Deploy, "Run docker stack deploy", SQUARECTL_TARGET, Squarectl::Tasks::Swarm.deploy(task, arguments.rest)
      leaf_command Setup, "Run Docker Swarm setup commands", SQUARECTL_TARGET, Squarectl::Tasks::Swarm.setup(task, arguments.rest)
      leaf_command Destroy, "Run docker stack rm", SQUARECTL_TARGET, Squarectl::Tasks::Swarm.destroy(task, arguments.rest)

      define_help description: "Run Docker Swarm commands"

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
      register_sub_command deploy, Deploy, description: "Run docker stack deploy"
      register_sub_command setup, Setup, description: "Run Docker Swarm setup commands"
      register_sub_command destroy, Destroy, description: "Run docker stack rm"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
