# Monkey-patch on Admiral's base command adding uniform handling for unknown
# subcommands/flags: run the block, and on any `Admiral::Error` print the error
# (only when arguments were actually given) followed by the help text and exit 1.
# Every command's `run` wraps its `super` in this.
abstract class Admiral::Command
  def rescue_unknown_cmd(&)
    begin
      yield
    rescue e : Admiral::Error
      unless @argv.empty?
        puts e.message.colorize(:red)
        puts ""
      end
    end
    puts help
    exit 1
  end
end
