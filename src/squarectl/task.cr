require "./commands/*"

module Squarectl
  # A fully resolved unit of work for a single (target, environment) pair.
  #
  # `TaskFactory` builds it by merging the global `all` environment with the
  # selected one; the `Tasks::*` orchestrators then call the command-building
  # methods mixed in from `Commands::*` (which ultimately shell out through the
  # injected `Executor`). Holding the merged values here means the command
  # builders never touch the raw config again.
  #
  # :nodoc:
  class Task
    include YAML::Serializable

    include Squarectl::Commands::Compose
    include Squarectl::Commands::Configs
    include Squarectl::Commands::Info
    include Squarectl::Commands::Kompose
    include Squarectl::Commands::Kubectl
    include Squarectl::Commands::Networks
    include Squarectl::Commands::Secrets
    include Squarectl::Commands::SetupCommands
    include Squarectl::Commands::SSLCertificates
    include Squarectl::Commands::Swarm

    getter target
    getter environment
    getter env_vars
    getter domains
    getter compose_files
    getter compose_networks
    getter ssl_certificates
    getter setup_commands
    getter deploy_server
    getter deploy_configs
    getter deploy_secrets

    def initialize(
      @target : String,
      @environment : Squarectl::Config::SquarectlEnvironment,
      @env_vars : Hash(String, String),
      @domains : Hash(String, String),
      @compose_files : Array(String),
      @compose_networks : Array(String),
      @ssl_certificates : Array(Hash(String, String)),
      @setup_commands : Array(Hash(String, String | Array(String))),
      @deploy_server : String,
      @deploy_configs : Hash(String, String),
      @deploy_secrets : Hash(String, String),
      @executor : Squarectl::Executor,
    )
    end

    # Docker Compose/Swarm project name, e.g. `myapp_staging`.
    def project_name
      "#{Squarectl.app_name}_#{environment.name}"
    end

    # `SQUARECTL_*` variables always injected into the child process so compose
    # files and setup commands can reference them.
    def runtime_env_vars
      {
        "SQUARECTL_CWD"       => Squarectl.root_dir.to_s,
        "SQUARECTL_APP"       => Squarectl.app_name,
        "SQUARECTL_TARGET"    => target,
        "SQUARECTL_ENV"       => environment.name,
        "SQUARECTL_ENV_SHORT" => environment.name[0..3],
      }
    end

    # Full environment handed to every spawned command: runtime vars overlaid
    # with the config's env vars and the derived domain vars.
    def task_env_vars
      runtime_env_vars.merge(env_vars).merge(domains)
    end

    # Turns the resolved compose file list into repeated `<prefix> <file>` argv
    # pairs, e.g. `--file a.yml --file b.yml`.
    def compose_files_args(prefix)
      compose_files.map { |_| prefix }.zip(compose_files).flat_map { |args| [args.first, args.last] }
    end
  end
end
