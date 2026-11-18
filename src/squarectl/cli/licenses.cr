module Squarectl
  class CLI < Admiral::Command
    # Prints the third-party notices embedded in the binary (`Squarectl::Licenses`).
    class Licenses < Admiral::Command
      define_help description: "Print the third-party notices embedded in this binary"

      def run
        print Squarectl::Licenses.text
      end
    end
  end
end
