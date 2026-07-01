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
