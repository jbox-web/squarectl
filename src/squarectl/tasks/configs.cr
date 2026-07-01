module Squarectl
  module Tasks
    # Orchestration layer for the `configs` command: create/destroy Docker Swarm
    # configs. Delegates to `Commands::Configs`.
    class Configs
      def self.create(task, args)
        task.create_docker_configs(args)
      end

      def self.destroy(task, args)
        task.destroy_docker_configs(args)
      end
    end
  end
end
