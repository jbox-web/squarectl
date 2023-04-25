module Squarectl
  # :nodoc:
  class TaskFactory
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

    def self.build_task_domains(target, environment, all)
      result = _build_task_domains(target, environment, all)
      decompose_urls(result)
    end

    def self.build_task_compose_files(target, environment, all)
      result = _build_task_compose_files(target, environment, all)
      result = result.map { |f| Squarectl.targets_common_dir.join(f) }
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

    def self.build_task_deploy_server(target, environment, all)
      env_server = environment.server.select { |e| find_matching_target(e, target) }
      env_server = env_server.empty? ? "" : env_server.first.host
      env_server
    end

    def self.build_task_deploy_configs(target, environment, all)
      all_config_files = all.nil? ? {} of String => String : all.config_files
      env_config_files = environment.config_files

      all_config_files = all_config_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }
      env_config_files = env_config_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }

      all_config_files = all_config_files.transform_values { |v| environment.root_dir.join(v).to_s }
      env_config_files = env_config_files.transform_values { |v| environment.root_dir.join(v).to_s }

      all_config_files.merge(env_config_files)
    end

    def self.build_task_deploy_secrets(target, environment, all)
      all_secret_files = all.nil? ? {} of String => String : all.secret_files
      env_secret_files = environment.secret_files

      all_secret_files = all_secret_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }
      env_secret_files = env_secret_files.transform_keys { |k| "#{Squarectl.app_name}-#{environment.short_name}__#{k}" }

      all_secret_files = all_secret_files.transform_values { |v| environment.root_dir.join(v).to_s }
      env_secret_files = env_secret_files.transform_values { |v| environment.root_dir.join(v).to_s }

      all_secret_files.merge(env_secret_files)
    end

    def self.find_matching_target(e, target)
      if e.target.is_a?(String)
        e.target == target || e.target == "all"
      elsif e.target.is_a?(Array)
        e.target.includes?(target)
      end
    end

    def self.decompose_urls(hash)
      new_hash = {} of String => String
      hash.each do |key, value|
        uri = URI.parse(value)

        # generate domain key
        domain_key = key.gsub("_URL", "_DOMAIN")
        new_hash[domain_key] = uri.host.not_nil! # ameba:disable Lint/NotNil

        # generate scheme key
        scheme_key = key.gsub("_URL", "_SCHEME")
        new_hash[scheme_key] = uri.scheme.not_nil! # ameba:disable Lint/NotNil
      end
      hash.merge(new_hash)
    end
  end
end
