import Config

config :elixir, ansi_enabled: true

# import_config "config_logger.exs"

# For testing purposes only...
config :file_only_logger,
  env: "#{Mix.env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"

if config_env() == :test do
  # To ensure all tests pass...
  config :file_only_logger, level: :all, line_length: 80, padding: "\s\s"
end
