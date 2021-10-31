module Squarectl
  module Commands
    module Swarm
      def run_docker_stack_deploy
        args = ["stack", "deploy", compose_files_args(prefix: "--compose-file"), "--prune", "--with-registry-auth", "--resolve-image", "always", project_name].flatten
        @executor.run_command("docker", args: args, env: task_env_vars.merge({"DOCKER_HOST" => deploy_server}))
      end

      def run_docker_stack_destroy
        args = ["stack", "rm", project_name]
        @executor.run_command("docker", args: args, env: {"DOCKER_HOST" => deploy_server})
      end

      def run_swarm_setup_commands
        setup_commands.each do |cmd|
          target = cmd["service"].as(String)
          command = cmd["command"].as(Array(String))

          container_id = get_swarm_container_id(target)

          if container_id.nil?
            puts "Container not found: #{target}"
          else
            args = ["exec", container_id] + command
            @executor.run_command("docker", args: args, env: {"DOCKER_HOST" => deploy_server})
          end
        end
      end

      private def get_swarm_container_id(target)
        stdout = IO::Memory.new
        stderr = IO::Memory.new
        args = ["ps", "--filter", "name=#{target}", "--format", "{{.ID}}"]
        status = Process.run("docker", shell: true, output: stdout, error: stderr, args: args, env: {"DOCKER_HOST" => deploy_server})
        status.success? ? stdout.to_s.chomp : nil
      end
    end
  end
end
