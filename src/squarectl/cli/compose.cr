module Squarectl
  class CLI < Admiral::Command
    class Compose < Admiral::Command
      SQUARECTL_TARGET = "compose"

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

      class Up < Admiral::Command
        define_help description: "Run docker-compose up"

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
          Squarectl::Tasks::Compose.up(task, arguments.rest)
        end
      end

      class Down < Admiral::Command
        define_help description: "Run docker-compose down"

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
          Squarectl::Tasks::Compose.down(task, arguments.rest)
        end
      end

      class Top < Admiral::Command
        define_help description: "Run docker-compose top"

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
          Squarectl::Tasks::Compose.top(task, arguments.rest)
        end
      end

      class Ps < Admiral::Command
        define_help description: "Run docker-compose ps"

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
          Squarectl::Tasks::Compose.ps(task, arguments.rest)
        end
      end

      class Setup < Admiral::Command
        define_help description: "Run docker-compose setup"

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
          Squarectl::Tasks::Compose.setup(task, arguments.rest)
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
          task = Squarectl::TaskFactory.build(SQUARECTL_TARGET, environment, Squarectl.environment_all)
          Squarectl::Tasks::Compose.exec(task, arguments.rest)
        end
      end

      class Copy < Admiral::Command
        define_help description: "Run docker-compose cp"

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
          Squarectl::Tasks::Compose.cp(task, arguments.rest)
        end
      end

      class Start < Admiral::Command
        define_help description: "Run docker-compose start"

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
          Squarectl::Tasks::Compose.start(task, arguments.rest)
        end
      end

      class Stop < Admiral::Command
        define_help description: "Run docker-compose stop"

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
          Squarectl::Tasks::Compose.stop(task, arguments.rest)
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
