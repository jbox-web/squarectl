module Squarectl
  module Commands
    module Kubectl
      def run_kubectl_apply
        args = ["apply", "-f", environment.kubernetes_dir.to_s]
        @executor.run_command("kubectl", args: args)
      end

      def run_kubectl_setup_commands
        setup_commands.each do |cmd|
          target = cmd["service"].as(String)
          command = cmd["command"].as(Array(String))

          container_id = get_kube_container_id(target)

          if container_id.nil?
            puts "Container not found: #{target}"
          else
            args = ["exec", container_id, "--"] + command
            @executor.run_command("kubectl", args: args)
          end
        end
      end

      private def get_kube_container_id(target)
        args = ["get", "pods", "--selector=io.kompose.service=#{target}", "--output=custom-columns=NAME:.metadata.name", "--no-headers=true"]
        @executor.capture_output("kubectl", args: args)
      end
    end
  end
end
