class Admiral::Command
  def rescue_unknown_cmd
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
