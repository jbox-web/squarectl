# Generates a standard leaf command class for the Admiral command tree.
#
# Every leaf command follows the same shape: a `--config`/`-c` flag, a required
# `environment` argument, and a `run` that loads the config, resolves the
# environment for the given target, builds a `Task` (wired to the injectable
# `Squarectl.executor`), and hands it to a `Tasks::*` method.
#
# The three commands that deviate from this shape keep bespoke definitions:
# `compose exec` (omits `-c` so it passes through), `kube convert` (extra
# `--output` flag) and `completion bash` (no config/environment).
#
# Parameters:
#   name        - the command class name (e.g. `Up`)
#   description - the help text
#   target      - the squarectl target ("compose"/"swarm"/"kubernetes"), usually
#                 the enclosing command's `SQUARECTL_TARGET` constant
#   task_call   - the `Tasks::*` call to run, referencing `task` and `arguments`
macro leaf_command(name, description, target, task_call)
  class {{name.id}} < Admiral::Command
    define_help description: {{description}}

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
      environment = Squarectl.find_environment(arguments.environment, {{target}})
      task = Squarectl::TaskFactory.build({{target}}, environment, Squarectl.environment_all, Squarectl.executor)
      {{task_call}}
    end
  end
end
