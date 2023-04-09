# Load std libs
require "json"
require "yaml"
require "file_utils"
require "uri"

# Load external libs
require "crystal-env/core"
require "admiral"
require "baked_file_system"
require "crinja"

# Set environment
Crystal::Env.default("development")

# Load squarectl
require "./squarectl/**"

module Squarectl
  VERSION = "1.4.1"

  @@environment_all : Squarectl::Config::SquarectlEnvironment?

  def self.version
    VERSION
  end

  def self.load_config(config_path)
    config_file = File.read(config_path)
    rendered = Crinja.render(config_file, {"ENV" => env_vars_to_hash})
    self.config = Squarectl::Config::SquarectlConfig.from_yaml(rendered)
    self.environments = config.environments
  end

  def self.reset_config!
    @@config = nil
    @@environments = nil
    @@environment_all = nil
  end

  def self.env_vars_to_hash
    hash = Hash(String, String).new
    ENV.each { |k, v| hash[k] = v }
    hash
  end

  private def self.config=(config : Squarectl::Config::SquarectlConfig)
    @@config = config
  end

  private def self.environments=(environments : Array(Squarectl::Config::SquarectlEnvironment))
    @@environments = environments
  end

  def self.config
    @@config ||= Squarectl::Config::SquarectlConfig.from_yaml("")
  end

  def self.environments
    @@environments || [] of Squarectl::Config::SquarectlEnvironment
  end

  def self.environment_all
    @@environment_all ||= environments.not_nil!.find { |e| e.name == "all" }
  end

  def self.find_environment(environment, target)
    raise "Target not found: #{target}" if !%w[compose swarm kubernetes].includes?(target)
    env = environments.not_nil!.find(&.name.includes?(environment))
    raise "Environment not found: #{environment}" if env.nil?
    raise "You can't use this command in development environment" if env.development? && target != "compose"
    env
  end

  def self.compose_v1?
    config.compose["version"] == 1
  end

  def self.app_name
    config.app
  end

  def self.root_dir
    Path.new(Dir.current)
  end

  def self.kubernetes_dir
    root_dir.join("kubernetes")
  end

  def self.data_dir
    root_dir.join("squarectl")
  end

  def self.targets_dir
    data_dir.join("targets")
  end

  def self.targets_common_dir
    targets_dir.join("common")
  end
end

# Start the CLI
unless Crystal.env.test?
  begin
    Squarectl::CLI.run
  rescue e : Exception
    puts e.message
    exit 1
  end
end
