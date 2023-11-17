import Config

# Log file paths...
debug_path = ~c"./log/debug.log"
info_path = ~c"./log/info.log"
warning_path = ~c"./log/warning.log"
error_path = ~c"./log/error.log"

# Configuration values...
format = "\n$date $time [$level] $message\n"
truncate_default_in_bytes = 8 * 1024
truncate_in_bytes = truncate_default_in_bytes
config = %{file: ??, file_check: 5000, max_no_bytes: 300_000, max_no_files: 5}

# By ascending log level...
colors = [
  debug: :light_cyan,
  info: :light_green,
  warning: :light_yellow,
  error: :light_red
]

formatter =
  Logger.Formatter.new(
    format: format,
    colors: [enabled: false],
    truncate: truncate_in_bytes
  )

config :logger, :default_formatter,
  format: format,
  colors: colors,
  truncate: truncate_in_bytes

config :file_only_logger, :logger, [
  # debug messages and above
  {:handler, :debug_handler, :logger_std_h,
   %{
     level: :debug,
     config: %{config | file: debug_path},
     formatter: formatter
   }},
  # info messages and above
  {:handler, :info_handler, :logger_std_h,
   %{
     level: :info,
     config: %{config | file: info_path},
     formatter: formatter
   }},
  # warning messages and above
  {:handler, :warning_handler, :logger_std_h,
   %{
     level: :warning,
     config: %{config | file: warning_path},
     formatter: formatter
   }},
  # error messages and above
  {:handler, :error_handler, :logger_std_h,
   %{
     level: :error,
     config: %{config | file: error_path},
     formatter: formatter
   }}
]

# Purges debug messages...
# config :logger, compile_time_purge_matching: [[level_lower_than: :info]]

# Keeps only error messages and above...
# config :logger, compile_time_purge_matching: [[level_lower_than: :error]]

# Logs only error messages and above...
# config :logger, level: :error

# line_length =
#   try do
#     {keyword, _binding} = Code.eval_file(".formatter.exs")
#     keyword[:line_length] || 98
#   rescue
#     _error -> 80
#   end

config :file_only_logger, line_length: 80, padding: "\s\s"
