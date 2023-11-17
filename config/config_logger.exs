import Config

# Log file paths...
debug_path = ~c"./log/debug.log"
info_path = ~c"./log/info.log"
warning_path = ~c"./log/warning.log"
error_path = ~c"./log/error.log"

# Listed by ascending log level...
colors = [
  debug: :light_cyan,
  info: :light_green,
  warning: :light_yellow,
  error: :light_red
]

app = Mix.Project.config()[:app]
format = "\n$date $time [$level] $message\n"
formatter = Logger.Formatter.new(format: format, colors: [enabled: false])
config = %{file: ??, file_check: 5000, max_no_bytes: 300_000, max_no_files: 5}

# config :logger, :default_handler, format: format, colors: colors
config :logger, :console, format: format, colors: colors

config app, :logger, [
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

# Prevents message truncation...
# truncate_default_in_bytes = 8 * 1024
#
# Logger.Formatter.new(
#   truncate: truncate_default_in_bytes * 2,
#   format: format,
#   colors: [enabled: false]
# )
