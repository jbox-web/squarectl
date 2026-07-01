module Squarectl
  module Tasks
    # Orchestration layer for the `kube` target. `convert` renders the merged
    # compose config and pipes it through kompose to (re)generate manifests into
    # the output dir; `apply`/`setup` then act on them via kubectl.
    class Kube
      # Renders the compose config and converts it to Kubernetes manifests.
      # Defaults the output to the environment's `kubernetes/<env>/` dir and
      # wipes any previous manifests there first.
      def self.convert(task, args, output)
        if output.empty?
          output = task.environment.not_nil!.kubernetes_dir.to_s # ameba:disable Lint/NotNil
          output = "#{output}/" unless output.ends_with?("/")
        end

        puts "Removing previous Kubernetes configuration: #{output}"
        FileUtils.rm_rf(output)

        config = task.capture_docker_compose("config", [] of String)

        args = ["--out", output] + args
        task.run_kompose_convert(config, args)
      end

      def self.apply(task, args)
        task.run_kubectl_apply
      end

      def self.setup(task, args)
        task.run_kubectl_setup_commands
      end
    end
  end
end
