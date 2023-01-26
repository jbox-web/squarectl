module Squarectl
  # :nodoc:
  class Executor
    def initialize(@output : IO::FileDescriptor | IO::Memory = STDOUT, @error : IO::FileDescriptor | IO::Memory = STDERR)
    end

    def run_command(cmd : String, args : Array(String))
      env = {} of String => String
      run_command(cmd, args, env)
    end

    def exec_command(cmd : String, args : Array(String))
      env = {} of String => String
      exec_command(cmd, args, env)
    end

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

    def run_command(cmd : String, args : Array(String), env : Hash(String, String))
      print_debug(cmd, args, env)

      status = Process.run(cmd, shell: true, output: @output, error: @error, args: args, env: env)
      status.success?
    end

    def exec_command(cmd : String, args : Array(String), env : Hash(String, String)) : NoReturn
      print_debug(cmd, args, env)

      Process.exec(cmd, shell: true, output: STDOUT, error: STDERR, args: args, env: env)
    end

    def run_command(cmd : String, args : Array(String), env : Hash(String, String), input : File)
      print_debug(cmd, args, env)

      status = Process.run(cmd, shell: true, output: @output, error: @error, args: args, env: env, input: input)
      status.success?
    end

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
