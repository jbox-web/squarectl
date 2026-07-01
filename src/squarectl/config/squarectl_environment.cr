module Squarectl
  module Config
    # A single deployment environment (e.g. `development`, `staging`,
    # `production`, or the special `all` holding global defaults). Groups every
    # resolvable attribute plus the conventional per-environment file locations.
    #
    # :nodoc:
    class SquarectlEnvironment
      include JSON::Serializable
      include YAML::Serializable

      property name : String
      property server : Array(Server) = [] of Server

      property env_vars : Array(EnvVar) = [] of EnvVar
      property networks : Array(Network) = [] of Network
      property compose_files : Array(ComposeFile) = [] of ComposeFile
      property domains : Array(Domain) = [] of Domain
      property ssl_certificates : Array(SSLCertificate) = [] of SSLCertificate
      property setup_commands : Array(SetupCommand) = [] of SetupCommand

      property config_files : Hash(String, String) = {} of String => String
      property secret_files : Hash(String, String) = {} of String => String

      # First 4 characters of the name, used to namespace swarm configs/secrets.
      def short_name
        name[0..3]
      end

      # The `development` environment is special-cased: it is only allowed with
      # the `compose` target (enforced in `Squarectl.find_environment`).
      def development?
        name == "development"
      end

      def root_dir
        Squarectl.root_dir
      end

      # Where generated Kubernetes manifests for this environment live.
      def kubernetes_dir
        Squarectl.kubernetes_dir.join(name)
      end

      # Conventional compose files always prepended to the resolved list, in load
      # order: the shared base, the per-target common file, then the
      # per-environment file.
      def compose_file_base_for(target)
        Squarectl.data_dir.join("base.yml")
      end

      # :ditto:
      def compose_file_common_for(target)
        Squarectl.targets_dir.join(target, "common.yml")
      end

      # :ditto:
      def compose_file_env_for(target)
        Squarectl.targets_dir.join(target, "#{name}.yml")
      end
    end
  end
end
