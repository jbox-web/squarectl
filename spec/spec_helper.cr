require "crystal-env/spec"
require "spectator"

# See: https://gitlab.com/arctic-fox/spectator/-/wikis/Configuration
Spectator.configure do |config|
  config.randomize
  config.profile
  config.after_each do
    Squarectl.reset_config!
  end
end

require "../src/squarectl"
