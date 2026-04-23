module Squarectl
  module Commands
    module Compose

      PRE_ARGS_BOOL = [
        "--all-resources",
        "--compatibility",
        "--dry-run",
      ]

      PRE_ARGS_FLAGS = [
        "--ansi",
        "--env-file",
        "--parallel",
        "--profile",
        "--progress",
        "--project-directory",
      ]

      def capture_docker_compose(action, args)
        tuple = build_docker_compose_command(action, args)
        @executor.capture_output(tuple[:cmd], args: tuple[:args], env: task_env_vars)
      end

      def run_docker_compose(action, args)
        tuple = build_docker_compose_command(action, args)
        @executor.run_command(tuple[:cmd], args: tuple[:args], env: task_env_vars)
      end

      def exec_docker_compose(action, args) : NoReturn
        tuple = build_docker_compose_command(action, args)
        @executor.exec_command(tuple[:cmd], args: tuple[:args], env: task_env_vars)
      end

      def build_docker_compose_command(action, args)
        cmd, prefix = Squarectl.compose_v1? ? {"docker-compose", nil} : {"docker", "compose"}
        pre_args, post_args = extract_docker_args(args)
        {cmd: cmd, args: [prefix, "--project-name", project_name, compose_files_args(prefix: "--file"), pre_args, action, post_args].compact.flatten}
      end

      def extract_docker_args(args)
        pre_args = [] of String
        post_args = [] of String
        i = 0

        while i < args.size
          arg = args[i]
          if PRE_ARGS_BOOL.includes?(arg)
            pre_args << arg
          elsif PRE_ARGS_FLAGS.includes?(arg)
            pre_args << arg
            i += 1
            pre_args << args[i] if i < args.size
          elsif PRE_ARGS_FLAGS.any? { |f| arg.starts_with?("#{f}=") }
            pre_args << arg
          else
            post_args << arg
          end
          i += 1
        end

        {pre_args, post_args}
      end
    end
  end
end
