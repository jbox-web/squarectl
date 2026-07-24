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

# Load patches
require "./admiral_patch"

# Load the leaf-command macro before the cli/ tree that uses it (the glob below
# does not guarantee it would be required first).
require "./squarectl/cli/leaf_command"

# Load squarectl
require "./squarectl/**"

# Top-level namespace and configuration holder.
#
# The parsed configuration is kept in class-level state (`@@config`,
# `@@environments`, `@@environment_all`) so that any component can reach it via
# `Squarectl.config` without threading it through. Because this state is global,
# specs must call `reset_config!` between examples (see `spec/spec_helper.cr`).
module Squarectl
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
  GIT_REF = {{ `git log -n 1 --format="%H" | head -c 8`.chomp.stringify }}

  @@environment_all : Squarectl::Config::SquarectlEnvironment?
  @@executor : Executor?

  # The `Executor` the CLI hands to every built `Task`. Memoized to a real
  # `Executor` by default; specs override it (`Squarectl.executor = mock`) to
  # capture the commands each subcommand dispatches without shelling out.
  def self.executor
    @@executor ||= Executor.new
  end

  def self.executor=(executor : Executor)
    @@executor = executor
  end

  # Human-readable version string, e.g. `1.6.0 (7347781a)`.
  def self.version
    "#{VERSION} (#{GIT_REF})"
  end

  # Reads the config file, renders it as a Crinja (Jinja) template with the
  # current process environment exposed as `ENV`, then parses the result as YAML.
  # This is why `{{ ENV.FOO }}` works inside `squarectl.yml`.
  def self.load_config(config_path)
    config_file = File.read(config_path)
    rendered = Crinja.render(config_file, {"ENV" => env_vars_to_hash})
    self.config = Squarectl::Config::SquarectlConfig.from_yaml(rendered)
    self.environments = config.environments
  end

  # Clears the cached config so a fresh one can be loaded. Used by the test suite.
  def self.reset_config!
    @@config = nil
    @@environments = nil
    @@environment_all = nil
    @@executor = nil
  end

  # Snapshot of the process environment as a plain hash, injected into the
  # Crinja template context.
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

  # The special `all` environment holding global defaults that `TaskFactory`
  # merges into every other environment. Returns `nil` when not defined.
  def self.environment_all
    @@environment_all ||= environments.not_nil!.find { |e| e.name == "all" } # ameba:disable Lint/NotNil
  end

  # Resolves the environment selected on the command line for the given target.
  # An exact name match wins; otherwise the name is treated as a substring
  # (`prod` matches `production`) but an ambiguous substring matching more than
  # one environment is rejected rather than silently picking the first. Raises on
  # an unknown target/environment, and forbids any non-`compose` target on the
  # `development` environment.
  def self.find_environment(environment, target)
    raise "Target not found: #{target}" if !%w[compose swarm kubernetes].includes?(target)

    envs = environments.not_nil! # ameba:disable Lint/NotNil
    env = envs.find { |e| e.name == environment }
    if env.nil?
      matches = envs.select(&.name.includes?(environment))
      raise "Environment not found: #{environment}" if matches.empty?
      raise "Ambiguous environment: #{environment} matches #{matches.map(&.name).join(", ")}" if matches.size > 1
      env = matches.first
    end

    raise "You can't use this command in development environment" if env.development? && target != "compose"
    env
  end

  # Whether the config requests Compose v1 (`docker-compose`) instead of v2
  # (`docker compose`). Drives the command prefix in `Commands::Compose`.
  def self.compose_v1?
    config.compose["version"] == 1
  end

  def self.app_name
    config.app
  end

  # Project directory conventions, all relative to the current working directory:
  #   root_dir/                       # the project (cwd)
  #   root_dir/kubernetes/<env>/      # generated Kubernetes manifests
  #   root_dir/squarectl/             # data_dir: base.yml lives here
  #   root_dir/squarectl/targets/     # per-target compose files (<target>/common.yml, <target>/<env>.yml)
  #   root_dir/squarectl/targets/common/  # extra compose files referenced by config
  def self.root_dir
    Path.new(Dir.current)
  end

  # :ditto:
  def self.kubernetes_dir
    root_dir.join("kubernetes")
  end

  # :ditto:
  def self.data_dir
    root_dir.join("squarectl")
  end

  # :ditto:
  def self.targets_dir
    data_dir.join("targets")
  end

  # :ditto:
  def self.targets_common_dir
    targets_dir.join("common")
  end
end

# Start the CLI, unless we are running under the spec suite (which requires the
# module without wanting the command dispatcher to fire). Any uncaught exception
# is reported as a message and turned into a non-zero exit code.
unless Crystal.env.test?
  begin
    Squarectl::CLI.run
  rescue e : Exception
    STDERR.puts e.message.presence || e.inspect_with_backtrace
    exit 1
  end
end
