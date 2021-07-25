module Squarectl
  module Tasks
    class Swarm
      def self.deploy(task, args)
        task.run_docker_stack_deploy
      end

      def self.destroy(task, args)
        task.run_docker_stack_destroy
      end

      def self.setup(task, args)
        task.run_swarm_setup_commands
      end
    end
  end
end
