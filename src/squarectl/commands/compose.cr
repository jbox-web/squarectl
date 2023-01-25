module Squarectl
  module Commands
    module Compose
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
        {cmd: cmd, args: [prefix, "--project-name", project_name, compose_files_args(prefix: "--file"), action, args].compact.flatten}
      end
    end
  end
end
