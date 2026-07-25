module Squarectl
  module Commands
    # Creates/removes the external Docker networks declared for the task
    # (before `compose up`, torn down on `clean`). Mixed into `Task`.
    module Networks
      def create_docker_networks
        compose_networks.each do |net|
          create_docker_network(net)
        end
      end

      def create_docker_network(net)
        args = ["network", "create", net]
        @executor.run_command("docker", args: args)
      rescue error : CommandError
        # `docker network create` exits non-zero when the network already exists.
        # Tolerate that (idempotent `up`) but only when the network is actually
        # present afterwards; re-raise any other creation failure. Checking the
        # post-condition avoids matching docker's stderr wording, which varies by
        # version and locale.
        raise error unless docker_network_exists?(net)
      end

      def docker_network_exists?(net)
        !@executor.capture_output("docker", args: ["network", "inspect", net]).nil?
      end

      def destroy_docker_networks
        compose_networks.each do |net|
          destroy_docker_network(net)
        end
      end

      def destroy_docker_network(net)
        args = ["network", "rm", net]
        @executor.run_command("docker", args: args)
      end
    end
  end
end
