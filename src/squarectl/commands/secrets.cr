module Squarectl
  module Commands
    # Creates/removes Docker Swarm secrets on the deploy server, piping each
    # source file into `docker secret create` via stdin. Mixed into `Task`.
    module Secrets
      def create_docker_secrets(args)
        deploy_secrets.each do |key, file|
          create_docker_secret(key, file)
        end
      end

      def create_docker_secret(key, file)
        args = ["secret", "create", key, "-"]
        File.open(file) do |input|
          @executor.run_command("docker", args: args, env: {"DOCKER_HOST" => deploy_server}, input: input)
        end
      end

      def destroy_docker_secrets(args)
        deploy_secrets.each do |key, file|
          destroy_docker_secret(key, file)
        end
      end

      def destroy_docker_secret(key, file)
        args = ["secret", "rm", key]
        @executor.run_command("docker", args: args, env: {"DOCKER_HOST" => deploy_server})
      end
    end
  end
end
