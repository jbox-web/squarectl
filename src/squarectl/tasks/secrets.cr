module Squarectl
  module Tasks
    # Orchestration layer for the `secrets` command: create/destroy Docker Swarm
    # secrets. Delegates to `Commands::Secrets`.
    class Secrets
      def self.create(task, args)
        task.create_docker_secrets(args)
      end

      def self.destroy(task, args)
        task.destroy_docker_secrets(args)
      end
    end
  end
end
