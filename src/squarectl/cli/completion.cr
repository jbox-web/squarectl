module Squarectl
  class CLI < Admiral::Command
    class Completion < Admiral::Command
      class Bash < Admiral::Command
        def run
          file = Squarectl::ShellCompletion.get("bash.sh")
          puts file.gets_to_end
        end
      end

      define_help description: "Install shell completion"

      register_sub_command bash, Bash, description: "Install Bash completion"

      def run
        rescue_unknown_cmd do
          super
        end
      end
    end
  end
end
