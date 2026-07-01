module Squarectl
  module Commands
    # Builds and runs `docker compose` (or `docker-compose` on v1) commands.
    # Mixed into `Task`; used directly by the `compose` target and reused by the
    # `kube` target to render the merged compose config before conversion.
    module Compose
      # docker-compose global flags that must appear *before* the action verb.
      # `PRE_ARGS_BOOL` take no value; `PRE_ARGS_FLAGS` take a following value (or
      # `--flag=value`). Everything else is treated as a post-action argument.
      PRE_ARGS_BOOL = [
        "--all-resources",
        "--compatibility",
        "--dry-run",
      ]

      # :ditto:
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

      # Assembles the full argv:
      #   <compose> --project-name <name> --file ... <pre-args> <action> <post-args>
      # On v2 the command is `docker` with a `compose` prefix arg; on v1 it is
      # `docker-compose` with no prefix (dropped via `compact`).
      def build_docker_compose_command(action, args)
        cmd, prefix = Squarectl.compose_v1? ? {"docker-compose", nil} : {"docker", "compose"}
        pre_args, post_args = extract_docker_args(args)
        {cmd: cmd, args: [prefix, "--project-name", project_name, compose_files_args(prefix: "--file"), pre_args, action, post_args].compact.flatten}
      end

      # Splits user-supplied args into those that belong before the action verb
      # (matched against `PRE_ARGS_BOOL`/`PRE_ARGS_FLAGS`, consuming a value for
      # the latter) and everything else, which goes after.
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
          elsif PRE_ARGS_FLAGS.any? { |flag| arg.starts_with?("#{flag}=") }
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
