module Squarectl
  module Tasks
    class Info
      def self.compose(task, args)
        task.print_info
      end

      def self.swarm(task, args)
        task.print_info
      end

      def self.kubernetes(task, args)
        task.print_info
      end
    end
  end
end
