module Squarectl
  module Tasks
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
