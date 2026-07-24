module Squarectl
  # Builds a fully resolved `Task` from the config.
  #
  # Each resolvable attribute (env vars, domains, compose files, networks, SSL
  # certificates, ...) is gathered from two sources — the global `all`
  # environment and the selected environment — keeping only entries whose
  # `target:` matches (see `find_matching_target`), then merged global-first so
  # the environment overrides the globals. The two `define_method_*` macros
  # generate this identical select/merge logic for hash- and array-shaped
  # attributes respectively.
  #
  # :nodoc:
  class TaskFactory
    # Generates a resolver for a hash-shaped attribute: selects matching entries
    # from `all` and the environment, reduces each side with `merge`, then merges
    # the environment result over the globals.
    macro define_method_hash(name, klass, default_key, default_value, accessor, method)
      def self.{{name.id}}(target, environment, all)
        all_objects = all.nil? ? [] of {{klass}} : all.{{accessor}}
        env_objects = environment.{{accessor}}

        all_objects = all_objects.select { |e| find_matching_target(e, target) }
        env_objects = env_objects.select { |e| find_matching_target(e, target) }

        all_objects = all_objects.empty? ? {} of {{default_key}} => {{default_value}} : all_objects.map(&.{{method}}).reduce({} of {{default_key}} => {{default_value}}) { |memo, i| memo.merge(i) }
        env_objects = env_objects.empty? ? {} of {{default_key}} => {{default_value}} : env_objects.map(&.{{method}}).reduce({} of {{default_key}} => {{default_value}}) { |memo, i| memo.merge(i) }

        all_objects.merge(env_objects)
      end
    end

    # Generates a resolver for an array-shaped attribute: same selection, but
    # concatenates (globals first, then environment) instead of merging.
    macro define_method_array(name, klass, default_value, accessor, method)
      def self.{{name.id}}(target, environment, all)

        all_objects = all.nil? ? [] of {{klass}} : all.{{accessor}}
        env_objects = environment.{{accessor}}

        all_objects = all_objects.select { |e| find_matching_target(e, target) }
        env_objects = env_objects.select { |e| find_matching_target(e, target) }

        all_objects = all_objects.empty? ? [] of {{default_value}} : all_objects.map(&.{{method}}).reduce([] of {{default_value}}) { |memo, i| memo + i }
        env_objects = env_objects.empty? ? [] of {{default_value}} : env_objects.map(&.{{method}}).reduce([] of {{default_value}}) { |memo, i| memo + i }

        all_objects + env_objects
      end
    end

    define_method_hash :_build_task_env_vars, Squarectl::Config::EnvVar, String, String, env_vars, vars
    define_method_hash :_build_task_domains, Squarectl::Config::Domain, String, String, domains, domains
    define_method_array :_build_task_compose_files, Squarectl::Config::ComposeFile, String, compose_files, files
    define_method_array :_build_task_compose_networks, Squarectl::Config::Network, String, networks, networks
    define_method_array :_build_task_ssl_certificates, Squarectl::Config::SSLCertificate, Squarectl::Config::SSLCertificateSpec, ssl_certificates, ssl_certificates

    # Resolves every attribute for the given (target, environment) pair — with
    # `all` supplying the global defaults — and assembles the `Task`. The
    # `executor` is injectable so specs can capture output instead of shelling out.
    def self.build(target, environment, all, executor = Executor.new)
      env_vars = build_task_env_vars(target, environment, all)
      domains = build_task_domains(target, environment, all)
      compose_files = build_task_compose_files(target, environment, all)
      compose_networks = build_task_compose_networks(target, environment, all)
      ssl_certificates = build_task_ssl_certificates(target, environment, all)
      setup_commands = build_task_setup_commands(target, environment, all)

      deploy_server = build_task_deploy_server(target, environment, all)
      deploy_configs = build_task_deploy_configs(target, environment, all)
      deploy_secrets = build_task_deploy_secrets(target, environment, all)

      Task.new(target, environment, env_vars, domains, compose_files, compose_networks, ssl_certificates, setup_commands, deploy_server, deploy_configs, deploy_secrets, executor)
    end

    def self.build_task_env_vars(target, environment, all)
      _build_task_env_vars(target, environment, all)
    end

    # Resolves domains, then expands any `*_URL` var into `*_DOMAIN`/`*_SCHEME`.
    def self.build_task_domains(target, environment, all)
      result = _build_task_domains(target, environment, all)
      decompose_urls(result)
    end

    # Resolves the compose file list. Config-declared files are looked up under
    # `squarectl/targets/common/`, and the conventional base files
    # (`base.yml`, `<target>/common.yml`, `<target>/<env>.yml`) are always
    # prepended so they load first.
    def self.build_task_compose_files(target, environment, all)
      result = _build_task_compose_files(target, environment, all)
      result = result.map { |file| Squarectl.targets_common_dir.join(file) }
      base_compose_files = [environment.compose_file_base_for(target), environment.compose_file_common_for(target), environment.compose_file_env_for(target)]
      (base_compose_files + result).map(&.to_s)
    end

    def self.build_task_compose_networks(target, environment, all)
      _build_task_compose_networks(target, environment, all)
    end

    def self.build_task_ssl_certificates(target, environment, all)
      result = _build_task_ssl_certificates(target, environment, all)
      result.map(&.to_h(environment))
    end

    def self.build_task_setup_commands(target, environment, all)
      all_setup_commands = all.nil? ? [] of Squarectl::Config::SetupCommand : all.setup_commands
      env_setup_commands = environment.setup_commands

      all_setup_commands = all_setup_commands.select { |e| find_matching_target(e, target) }
      env_setup_commands = env_setup_commands.select { |e| find_matching_target(e, target) }

      (all_setup_commands + env_setup_commands).map(&.to_h)
    end

    # The remote Docker host (`DOCKER_HOST`) for swarm deploys — the first
    # matching `server` entry's host, or empty when none is declared.
    def self.build_task_deploy_server(target, environment, all)
      env_server = environment.server.select { |e| find_matching_target(e, target) }
      env_server = env_server.empty? ? "" : env_server.first.host
      env_server
    end

    # Resolves swarm config files. Keys are namespaced as
    # `<app>-<envshort>__<key>` and values resolved to absolute paths.
    def self.build_task_deploy_configs(target, environment, all)
      all_config_files = all.nil? ? {} of String => String : all.config_files
      env_config_files = environment.config_files

      all_config_files = all_config_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }
      env_config_files = env_config_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }

      all_config_files = all_config_files.transform_values { |v| environment.root_dir.join(v).to_s }
      env_config_files = env_config_files.transform_values { |v| environment.root_dir.join(v).to_s }

      all_config_files.merge(env_config_files)
    end

    # Resolves swarm secret files. Same namespacing and path resolution as
    # `build_task_deploy_configs`.
    def self.build_task_deploy_secrets(target, environment, all)
      all_secret_files = all.nil? ? {} of String => String : all.secret_files
      env_secret_files = environment.secret_files

      all_secret_files = all_secret_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }
      env_secret_files = env_secret_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }

      all_secret_files = all_secret_files.transform_values { |v| environment.root_dir.join(v).to_s }
      env_secret_files = env_secret_files.transform_values { |v| environment.root_dir.join(v).to_s }

      all_secret_files.merge(env_secret_files)
    end

    # A config entry applies to a target when its `target:` is that string (or
    # the wildcard `"all"`), or when it is an array that includes the target.
    def self.find_matching_target(e, target)
      if e.target.is_a?(String)
        e.target == target || e.target == "all"
      elsif e.target.is_a?(Array)
        e.target.includes?(target)
      end
    end

    # For every entry whose key ends with `_URL`, derives sibling `*_DOMAIN` and
    # `*_SCHEME` vars from the parsed URI and merges them in, so compose files can
    # reference the parts separately. Non-`_URL` keys are left untouched, and a
    # `_URL` value missing a host or scheme is skipped rather than crashing.
    def self.decompose_urls(hash)
      new_hash = {} of String => String
      hash.each do |key, value|
        next unless key.ends_with?("_URL")

        uri = URI.parse(value)

        # generate domain key (only when the URI actually has a host)
        if host = uri.host
          new_hash[key.sub(/_URL$/, "_DOMAIN")] = host
        end

        # generate scheme key (only when the URI actually has a scheme)
        if scheme = uri.scheme
          new_hash[key.sub(/_URL$/, "_SCHEME")] = scheme
        end
      end
      hash.merge(new_hash)
    end
  end
end
