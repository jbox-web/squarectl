module Squarectl
  module Commands
    module Kompose
      def run_kompose(action, args)
        @executor.run_command("kompose", args: kompose_args(action, args), env: task_env_vars)
      end

      private def kompose_args(action, args)
        [compose_files_args(prefix: "--file"), action, args].flatten
      end
    end
  end
end
