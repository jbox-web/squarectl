module Squarectl
  module Commands
    module SetupCommands
      def run_docker_compose_setup_commands
        setup_commands.each do |cmd|
          target = cmd["service"].as(String)
          command = cmd["command"].as(Array(String))

          # Prepend command with -T to avoid error: the input device is not a TTY
          # See: https://github.com/docker/compose/issues/7306#issuecomment-632018976
          args = ["-T", target] + command
          run_docker_compose("exec", args: args)
        end
      end
    end
  end
end
