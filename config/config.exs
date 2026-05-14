import Config

config :elixir, ansi_enabled: true

# import_config "config_logger.exs"

# Changes here require to recompile app :file_only_logger.
config :file_only_logger, line_length: 80, padding: "\s\s"

# For testing purposes only...
config :file_only_logger,
  env: "#{Mix.env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"
