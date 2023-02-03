import Config

config :file_only_logger, nonexistent_module: File.Only.Logger.DeleteLogFiles

# Logging levels ordered by importance or severity...
# However :warning and :warn have the same severity...
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

# line_length =
#   try do
#     {keyword, _binding} = Code.eval_file(".formatter.exs")
#     keyword[:line_length] || 98
#   rescue
#     _error -> 80
#   end

config :file_only_logger, line_length: 80, padding: "\s\s"
