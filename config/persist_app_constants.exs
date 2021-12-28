import Config

config :file_only_logger, after_compile: File.Only.Logger.DeleteLogFiles

# Logging levels ordered by importance or severity...
config :file_only_logger,
  levels: [
    :emergency,
    :alert,
    :critical,
    :error,
    :warning,
    :warn,
    :notice,
    :info,
    :debug
  ]

config :file_only_logger, test_wait: 222
