# File-Only Logger

A simple logger that writes messages to log files only (not to the console).

## Installation

Add `file_only_logger` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:file_only_logger, "~> 0.1.0"}
  ]
end
```

## Usage

Trying to log any message with severity less than the configured level will
simply cause the message to be ignored.

The configuration values for log level are:

- :all (default)
- :none
- [Logger.level()](https://hexdocs.pm/logger/Logger.html#t:level/0)

You may use file `config/runtime.exs` to configure the above log level:

```elixir
import Config

config :file_only_logger, level: :info
```

#### Example

```elixir
defmodule Log do
  use File.Only.Logger

  warn :error_occurred, {reason, file} do
    """
    \n'error' occurred...
    Reason => '#{:file.format_error(reason)}'
    File => "#{Path.relative_to_cwd(file)}"
    """
  end
end

defmodule Check do
  def log_warn do
    Log.warn(:error_occurred, {:enoent, __ENV__.file})
  end
end

Check.log_warn() # => will log something like so in the configured log file(s):

2023-02-09 16:39:19.763 [warn]
'error' occurred...
Reason => 'no such file or directory'
File => "lib/file/only/logger/ie.ex"
```
