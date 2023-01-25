module Squarectl
  module Commands
    module Kompose
      def run_kompose_convert(config, args)
        tempfile = File.tempfile("docker-compose", &.print(config))
        args = ["--file", tempfile.path.to_s, "convert", args].flatten
        @executor.run_command("kompose", args: args, env: task_env_vars)
      end

      def run_kompose(action, args)
        @executor.run_command("kompose", args: kompose_args(action, args), env: task_env_vars)
      end

      private def kompose_args(action, args)
        [compose_files_args(prefix: "--file"), action, args].flatten
      end
    end
  end
end
