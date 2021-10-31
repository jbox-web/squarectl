module Squarectl
  module Commands
    module Compose
      def run_docker_compose(action, args)
        @executor.run_command("docker-compose", args: docker_compose_args(action, args), env: task_env_vars)
      end

      def exec_docker_compose(action, args)
        @executor.exec_command("docker-compose", args: docker_compose_args(action, args), env: task_env_vars)
      end

      private def docker_compose_args(action, args)
        ["--project-name", project_name, compose_files_args(prefix: "--file"), action, args].flatten
      end
    end
  end
end
