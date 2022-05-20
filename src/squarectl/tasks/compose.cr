module Squarectl
  module Tasks
    class Compose
      def self.config(task, args)
        task.exec_docker_compose("config", args)
      end

      def self.build(task, args)
        args = ["--pull"] + args
        task.exec_docker_compose("build", args)
      end

      def self.push(task, args)
        task.exec_docker_compose("push", args)
      end

      def self.clean(task, args)
        # Run docker compose down
        args = ["--rmi", "all", "-v"] + args
        task.run_docker_compose("down", args)

        # Destroy declared Docker networks
        task.destroy_docker_networks

        # Destroy declared SSL certificates
        task.destroy_ssl_certificates
      end

      def self.up(task, args)
        # Create declared SSL certificates
        task.create_ssl_certificates

        # Create declared Docker networks
        task.create_docker_networks

        # Run docker compose up
        args = ["--remove-orphans"] + args
        task.exec_docker_compose("up", args)
      end

      def self.down(task, args)
        task.exec_docker_compose("down", args)
      end

      def self.top(task, args)
        task.exec_docker_compose("top", args)
      end

      def self.ps(task, args)
        task.exec_docker_compose("ps", args)
      end

      def self.setup(task, args)
        task.run_docker_compose_setup_commands
      end

      def self.exec(task, args)
        task.exec_docker_compose("exec", args)
      end

      def self.start(task, args)
        task.exec_docker_compose("start", args)
      end

      def self.stop(task, args)
        task.exec_docker_compose("stop", args)
      end
    end
  end
end
