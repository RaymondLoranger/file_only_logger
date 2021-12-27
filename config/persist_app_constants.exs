import Config

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
