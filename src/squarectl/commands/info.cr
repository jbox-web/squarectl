module Squarectl
  module Commands
    module Info
      def squarectl_environment
        {
          "SQUARECTL_APP"                => Squarectl.app_name,
          "SQUARECTL_ENV"                => environment.name,
          "SQUARECTL_TARGET"             => target,
          "SQUARECTL_TARGET_SERVER"      => deploy_server,
          "SQUARECTL_CWD"                => Squarectl.root_dir,
          "SQUARECTL_DATA_DIR"           => Squarectl.data_dir,
          "SQUARECTL_TARGETS_DIR"        => Squarectl.targets_dir,
          "SQUARECTL_TARGETS_COMMON_DIR" => Squarectl.targets_common_dir,
          "SQUARECTL_ENV_VARS"           => env_vars,
          "SQUARECTL_DOMAINS"            => domains,
          "SQUARECTL_FILES"              => compose_files,
          "SQUARECTL_NETWORKS"           => compose_networks,
          "SQUARECTL_SSL_CERTIFICATES"   => ssl_certificates,
          "SQUARECTL_SETUP_COMMANDS"     => setup_commands,
          "SQUARECTL_CONFIG_FILES"       => deploy_configs,
          "SQUARECTL_SECRET_FILES"       => deploy_secrets,
        }
      end

      def print_info
        puts YAML.dump(squarectl_environment)
      end
    end
  end
end
