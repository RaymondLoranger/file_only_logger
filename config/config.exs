import Config

import_config "config_logger.exs"

# For testing purposes only...
config :file_only_logger,
  env: "#{Mix.env()} ➔ from #{Path.relative_to_cwd(__ENV__.file)}"

{keyword, _binding} = Code.eval_file(".formatter.exs")
config :file_only_logger, limit: keyword[:line_length] || 98
