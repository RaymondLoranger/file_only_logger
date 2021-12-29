import Config

import_config "config_logger.exs"

# For testing purposes only...
config :file_only_logger,
  env: "#{Mix.env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"

line_length =
  try do
    {keyword, _binding} = Code.eval_file(".formatter.exs")
    keyword[:line_length] || 98
  rescue
    _error -> 80
  end

config :file_only_logger, line_length: line_length
