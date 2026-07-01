module Squarectl
  module Tasks
    # Orchestration layer for the `info` command: prints the resolved task as
    # YAML. The per-target methods are identical hooks kept for CLI symmetry.
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
