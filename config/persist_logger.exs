import Config

# Logger configuration values...
config :file_only_logger, format: "\n$date $time [$level] $message\n"
config :file_only_logger, truncate_default_in_bytes: 8 * 1024

config :file_only_logger,
  config: %{file: ??, file_check: 5000, max_no_bytes: 300_000, max_no_files: 5}

# Logger colors by ascending log level...
config :file_only_logger,
  colors: [
    debug: :light_cyan,
    info: :light_green,
    warning: :light_yellow,
    error: :light_red
  ]
