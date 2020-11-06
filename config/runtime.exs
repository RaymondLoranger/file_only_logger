import Config

config :file_only_logger, log?: config_env() in [:prod, :dev]

# For testing purposes only...
config :file_only_logger, env: "*** #{config_env()} ***"
config :file_only_logger, runtime?: :yes_indeed
