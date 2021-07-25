module Squarectl
  module Tasks
    class Kube
      def self.convert(task, args, output)
        if output.empty?
          output = task.environment.kubernetes_dir.to_s
          output = "#{output}/" unless output.ends_with?("/")

          puts "Removing previous Kubernetes configuration: #{output}"
          FileUtils.rm_rf(output)
        end

        args = ["--out", output, "--with-kompose-annotation=false"] + args
        task.run_kompose("convert", args)
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
