module Squarectl
  module Tasks
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
