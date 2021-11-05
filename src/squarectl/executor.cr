module Squarectl
  # :nodoc:
  class Executor
    def run_command(cmd : String, args : Array(String))
      env = {} of String => String
      run_command(cmd, args, env)
    end

    def exec_command(cmd : String, args : Array(String))
      env = {} of String => String
      exec_command(cmd, args, env)
    end

    def run_command(cmd : String, args : Array(String), env : Hash(String, String))
      print_debug(cmd, args, env)

      status = Process.run(cmd, shell: true, output: STDOUT, error: STDERR, args: args, env: env)
      status.success?
    end

    def exec_command(cmd : String, args : Array(String), env : Hash(String, String))
      print_debug(cmd, args, env)

      Process.exec(cmd, shell: true, output: STDOUT, error: STDERR, args: args, env: env)
    end

    def run_command(cmd : String, args : Array(String), env : Hash(String, String), input : File)
      print_debug(cmd, args, env)

      status = Process.run(cmd, shell: true, output: STDOUT, error: STDERR, args: args, env: env, input: input)
      status.success?
    end

    private def print_debug(cmd, args, env)
      if ENV["SQUARECTL_DEBUG"]? && ENV["SQUARECTL_DEBUG"] == "true"
        debug = {
          "CMDLINE" => [cmd, args].flatten,
          "ENV"     => env,
        }
        puts YAML.dump(debug)
      end
    end
  end
end
