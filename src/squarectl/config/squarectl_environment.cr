module Squarectl
  module Config
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

      def short_name
        name[0..3]
      end

      def development?
        name == "development"
      end

      def root_dir
        Squarectl.root_dir
      end

      def kubernetes_dir
        Squarectl.kubernetes_dir.join(name)
      end

      def compose_file_base_for(target)
        Squarectl.data_dir.join("base.yml")
      end

      def compose_file_common_for(target)
        Squarectl.targets_dir.join(target, "common.yml")
      end

      def compose_file_env_for(target)
        Squarectl.targets_dir.join(target, "#{name}.yml")
      end
    end
  end
end
