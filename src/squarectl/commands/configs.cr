module Squarectl
  module Commands
    module Configs
      def create_docker_configs(args)
        deploy_configs.each do |key, file|
          create_docker_config(key, file)
        end
      end

      def create_docker_config(key, file)
        args = ["config", "create", key, "-"]
        @executor.run_command("docker", args: args, env: {"DOCKER_HOST" => deploy_server}, input: File.open(file))
      end

      def destroy_docker_configs(args)
        deploy_configs.each do |key, file|
          destroy_docker_config(key, file)
        end
      end

      def destroy_docker_config(key, file)
        args = ["config", "rm", key]
        @executor.run_command("docker", args: args, env: {"DOCKER_HOST" => deploy_server})
      end
    end
  end
end
