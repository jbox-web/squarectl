module Squarectl
  class CLI < Admiral::Command
    class Compose < Admiral::Command
      SQUARECTL_TARGET = "compose"

      leaf_command Config, "Run docker-compose config", SQUARECTL_TARGET, Squarectl::Tasks::Compose.config(task, arguments.rest)
      leaf_command Build, "Run docker-compose build", SQUARECTL_TARGET, Squarectl::Tasks::Compose.build(task, arguments.rest)
      leaf_command Push, "Run docker-compose push", SQUARECTL_TARGET, Squarectl::Tasks::Compose.push(task, arguments.rest)
      leaf_command Up, "Run docker-compose up", SQUARECTL_TARGET, Squarectl::Tasks::Compose.up(task, arguments.rest)
      leaf_command Down, "Run docker-compose down", SQUARECTL_TARGET, Squarectl::Tasks::Compose.down(task, arguments.rest)
      leaf_command Top, "Run docker-compose top", SQUARECTL_TARGET, Squarectl::Tasks::Compose.top(task, arguments.rest)
      leaf_command Ps, "Run docker-compose ps", SQUARECTL_TARGET, Squarectl::Tasks::Compose.ps(task, arguments.rest)
      leaf_command Setup, "Run docker-compose setup", SQUARECTL_TARGET, Squarectl::Tasks::Compose.setup(task, arguments.rest)
      leaf_command Clean, "Run docker-compose clean", SQUARECTL_TARGET, Squarectl::Tasks::Compose.clean(task, arguments.rest)
      leaf_command Copy, "Run docker-compose cp", SQUARECTL_TARGET, Squarectl::Tasks::Compose.cp(task, arguments.rest)
      leaf_command Start, "Run docker-compose start", SQUARECTL_TARGET, Squarectl::Tasks::Compose.start(task, arguments.rest)
      leaf_command Stop, "Run docker-compose stop", SQUARECTL_TARGET, Squarectl::Tasks::Compose.stop(task, arguments.rest)

      # `exec` keeps a bespoke definition: it intentionally omits the `-c` short
      # flag so that a `-c` in the user's arguments is passed through to the
      # executed command instead of being consumed as squarectl's config flag.
      class Exec < Admiral::Command
        define_help description: "Run docker-compose exec"

        # ameba:disable Lint/UselessAssign
        define_flag config : String,
          description: "Path to config file",
          long: "config",
          default: "squarectl.yml"

        # ameba:disable Lint/UselessAssign
        define_argument environment : String,
          description: "Squarectl ENVIRONMENT",
          required: true

        def run
          Squarectl.load_config(flags.config)
          environment = Squarectl.find_environment(arguments.environment, SQUARECTL_TARGET)
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all, Squarectl.executor)
          Squarectl::Tasks::Compose.exec(task, arguments.rest)
        end
      end

      define_help description: "Run Docker Compose commands"

      # ameba:disable Lint/UselessAssign
      define_flag config : String,
        description: "Path to config file",
        long: "config",
        short: "c",
        default: "squarectl.yml"

      register_sub_command config, Config, description: "Run docker-compose config"
      register_sub_command build, Build, description: "Run docker-compose build"
      register_sub_command push, Push, description: "Run docker-compose push"
      register_sub_command up, Up, description: "Run docker-compose up"
      register_sub_command down, Down, description: "Run docker-compose down"
      register_sub_command top, Top, description: "Run docker-compose top"
      register_sub_command ps, Ps, description: "Run docker-compose ps"
      register_sub_command setup, Setup, description: "Run docker-compose setup"
      register_sub_command clean, Clean, description: "Run docker-compose clean"
      register_sub_command exec, Exec, description: "Run docker-compose exec"
      register_sub_command cp, Copy, description: "Run docker-compose cp"
      register_sub_command start, Start, description: "Run docker-compose start"
      register_sub_command stop, Stop, description: "Run docker-compose stop"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
