module Squarectl
  # Embeds the shell completion scripts from `completion/` into the binary (via
  # BakedFileSystem) so `squarectl completion bash` can print them at runtime
  # without shipping separate files.
  #
  # :nodoc:
  class ShellCompletion
    extend BakedFileSystem
    bake_folder "../../completion"
  end
end
