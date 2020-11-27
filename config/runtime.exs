import Config

# Should be configured in the parent app...
# config :file_only_logger, log?: true

# For testing purposes only...
config :file_only_logger,
  env: "#{config_env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"
