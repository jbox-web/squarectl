module Squarectl
  # :nodoc:
  class TaskFactory
    def self.build(target, environment, all)
      env_vars = build_task_env_vars(target, environment, all)
      domains = build_task_domains(target, environment, all)
      compose_files = build_task_compose_files(target, environment, all)
      compose_networks = build_task_compose_networks(target, environment, all)
      ssl_certificates = build_task_ssl_certificates(target, environment, all)
      setup_commands = build_task_setup_commands(target, environment, all)

      deploy_server = build_task_deploy_server(target, environment, all)
      deploy_configs = build_task_deploy_configs(target, environment, all)
      deploy_secrets = build_task_deploy_secrets(target, environment, all)

      Task.new(target, environment, env_vars, domains, compose_files, compose_networks, ssl_certificates, setup_commands, deploy_server, deploy_configs, deploy_secrets)
    end

    def self.build_task_env_vars(target, environment, all)
      all_env_vars = all.nil? ? [] of Squarectl::Config::EnvVar : all.env_vars
      env_env_vars = environment.env_vars

      all_env_vars = all_env_vars.select { |e| find_matching_target(e, target) }
      env_env_vars = env_env_vars.select { |e| find_matching_target(e, target) }

      all_env_vars = all_env_vars.empty? ? {} of String => String : all_env_vars.map { |e| e.vars }.reduce({} of String => String) { |memo, i| memo.merge(i) }
      env_env_vars = env_env_vars.empty? ? {} of String => String : env_env_vars.map { |e| e.vars }.reduce({} of String => String) { |memo, i| memo.merge(i) }

      all_env_vars.merge(env_env_vars)
    end

    def self.build_task_domains(target, environment, all)
      all_domains = all.nil? ? [] of Squarectl::Config::Domain : all.domains
      env_domains = environment.domains

      all_domains = all_domains.select { |e| find_matching_target(e, target) }
      env_domains = env_domains.select { |e| find_matching_target(e, target) }

      all_domains = all_domains.empty? ? {} of String => String : all_domains.first.domains
      env_domains = env_domains.empty? ? {} of String => String : env_domains.first.domains

      decompose_urls(all_domains.merge(env_domains))
    end

    def self.build_task_compose_files(target, environment, all)
      all_compose_files = all.nil? ? [] of Squarectl::Config::ComposeFile : all.compose_files
      env_compose_files = environment.compose_files

      all_compose_files = all_compose_files.select { |e| find_matching_target(e, target) }
      env_compose_files = env_compose_files.select { |e| find_matching_target(e, target) }

      all_compose_files = all_compose_files.empty? ? [] of String : all_compose_files.map(&.files).reduce([] of String) { |memo, i| memo + i }
      env_compose_files = env_compose_files.empty? ? [] of String : env_compose_files.map(&.files).reduce([] of String) { |memo, i| memo + i }

      all_compose_files = all_compose_files.map { |f| Squarectl.targets_common_dir.join(f) }
      env_compose_files = env_compose_files.map { |f| Squarectl.targets_common_dir.join(f) }

      base_compose_files = [environment.compose_file_base_for(target), environment.compose_file_common_for(target), environment.compose_file_env_for(target)]
      (base_compose_files + all_compose_files + env_compose_files).map(&.to_s)
    end

    def self.build_task_compose_networks(target, environment, all)
      all_compose_networks = all.nil? ? [] of Squarectl::Config::Network : all.networks
      env_compose_networks = environment.networks

      all_compose_networks = all_compose_networks.select { |e| find_matching_target(e, target) }
      env_compose_networks = env_compose_networks.select { |e| find_matching_target(e, target) }

      all_compose_networks = all_compose_networks.empty? ? [] of String : all_compose_networks.map(&.networks).reduce([] of String) { |memo, i| memo + i }
      env_compose_networks = env_compose_networks.empty? ? [] of String : env_compose_networks.map(&.networks).reduce([] of String) { |memo, i| memo + i }

      all_compose_networks + env_compose_networks
    end

    def self.build_task_ssl_certificates(target, environment, all)
      all_ssl_certificates = all.nil? ? [] of Squarectl::Config::SSLCertificate : all.ssl_certificates
      env_ssl_certificates = environment.ssl_certificates

      all_ssl_certificates = all_ssl_certificates.select { |e| find_matching_target(e, target) }
      env_ssl_certificates = env_ssl_certificates.select { |e| find_matching_target(e, target) }

      all_ssl_certificates = all_ssl_certificates.empty? ? [] of Squarectl::Config::SSLCertificateSpec : all_ssl_certificates.first.ssl_certificates
      env_ssl_certificates = env_ssl_certificates.empty? ? [] of Squarectl::Config::SSLCertificateSpec : env_ssl_certificates.first.ssl_certificates

      (all_ssl_certificates + env_ssl_certificates).map(&.to_h(environment))
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
        new_hash[domain_key] = uri.host.not_nil!

        # generate scheme key
        scheme_key = key.gsub("_URL", "_SCHEME")
        new_hash[scheme_key] = uri.scheme.not_nil!
      end
      hash.merge(new_hash)
    end
  end
end
