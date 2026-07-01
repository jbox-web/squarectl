module Squarectl
  # The single point where child processes are spawned.
  #
  # Everything squarectl does eventually funnels through here, which is what
  # makes the rest of the code testable: specs inject an `Executor` whose output
  # is an `IO::Memory` to capture commands instead of running them. Three modes:
  # `run_command` (spawn and wait for success), `exec_command` (replace the
  # current process — never returns) and `capture_output` (collect stdout).
  #
  # :nodoc:
  class Executor
    def initialize(@output : IO::FileDescriptor | IO::Memory = STDOUT, @error : IO::FileDescriptor | IO::Memory = STDERR)
    end

    # :ditto:
    def run_command(cmd : String, args : Array(String))
      env = {} of String => String
      run_command(cmd, args, env)
    end

    # :ditto:
    def exec_command(cmd : String, args : Array(String))
      env = {} of String => String
      exec_command(cmd, args, env)
    end

    # Runs the command and returns its trimmed stdout, or `nil` if it failed.
    def capture_output(cmd : String, args : Array(String))
      stdout = IO::Memory.new
      stderr = IO::Memory.new
      status = Process.run(cmd, shell: true, output: stdout, error: stderr, args: args)
      status.success? ? stdout.to_s.chomp : nil
    end

    def capture_output(cmd : String, args : Array(String), env : Hash(String, String))
      stdout = IO::Memory.new
      stderr = IO::Memory.new
      status = Process.run(cmd, shell: true, output: stdout, error: stderr, args: args, env: env)
      status.success? ? stdout.to_s.chomp : nil
    end

    # Spawns the command, waits for it, and returns whether it succeeded.
    def run_command(cmd : String, args : Array(String), env : Hash(String, String))
      print_debug(cmd, args, env)

      status = Process.run(cmd, shell: true, output: @output, error: @error, args: args, env: env)
      status.success?
    end

    # Replaces the current process with the command; used for interactive
    # commands (e.g. `compose up`, `exec`) so signals and the TTY pass through.
    def exec_command(cmd : String, args : Array(String), env : Hash(String, String)) : NoReturn
      print_debug(cmd, args, env)

      Process.exec(cmd, shell: true, output: STDOUT, error: STDERR, args: args, env: env)
    end

    # Variant that streams a file to the command's stdin (used to pipe config and
    # secret contents into `docker config/secret create`).
    def run_command(cmd : String, args : Array(String), env : Hash(String, String), input : File)
      print_debug(cmd, args, env)

      status = Process.run(cmd, shell: true, output: @output, error: @error, args: args, env: env, input: input)
      status.success?
    end

    # When `SQUARECTL_DEBUG=true`, dumps the command line and environment as YAML
    # before running it.
    private def print_debug(cmd, args, env)
      if ENV["SQUARECTL_DEBUG"]? && ENV["SQUARECTL_DEBUG"] == "true"
        debug = {
          "CMDLINE"     => [cmd, args].flatten,
          "CMDLINE_STR" => [cmd, args].flatten.join(" "),
          "ENV"         => env,
        }
        puts YAML.dump(debug)
      end
    end
  end
end
