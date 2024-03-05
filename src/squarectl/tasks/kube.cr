module Squarectl
  module Tasks
    class Kube
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
