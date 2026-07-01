module Squarectl
  module Config
    # A set of domain variables scoped to one or more targets. Any `*_URL` entry
    # is expanded into `*_DOMAIN`/`*_SCHEME` by `TaskFactory.decompose_urls`.
    #
    # :nodoc:
    class Domain
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property domains : Hash(String, String) = {} of String => String
    end
  end
end
