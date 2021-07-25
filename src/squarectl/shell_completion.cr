module Squarectl
  # :nodoc:
  class ShellCompletion
    extend BakedFileSystem
    bake_folder "../../completion"
  end
end
