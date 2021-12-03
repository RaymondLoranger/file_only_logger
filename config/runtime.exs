import Config

# Examples of runtime configurations in the parent app...
#
#   config :file_only_logger, level: :all (default)
#   config :file_only_logger, level: :none
#   config :file_only_logger, level: :info

# For testing purposes only...
config :file_only_logger,
  env: "#{config_env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"
