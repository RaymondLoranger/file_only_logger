# FileOnly Logger

A simple logger that writes messages to log files only (not to the console).
Elixir's Logger Backends were abandoned in favor of Erlang's Logger handlers.

## Installation

Add `file_only_logger` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:file_only_logger, "~> 0.2.0"}
  ]
end
```

Proper configuration must be set via config files. See files `config/config.exs`
and `config/config_logger.exs` as an example (including log file rotation).

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

  warning :error_occurred, {reason, file, env} do
    """
    \n'error' occurred...
    Reason => '#{:file.format_error(reason)}'
    File => #{Path.expand(file) |> inspect() |> maybe_break(8)}
    #{from(env, __MODULE__)}\
    """
  end
end

defmodule Check do
  def log_warning(file) do
    Log.warning(:error_occurred, {:enoent, file, __ENV__})
  end
end

Check.log_warning(__ENV__.file)
Check.log_warning("generate-line-break")
# will respectively log these lines in the configured log file(s):

2025-01-13 12:27:14.532 [warning]
'error' occurred...
Reason => 'no such file or directory'
File => "c:/Users/Ray/Documents/ex_dev/projects/file_only_logger/iex"
• App: undefined
• Module: Log
• Function: Check.log_warning/1

2025-01-13 12:30:46.370 [warning]
'error' occurred...
Reason => 'no such file or directory'
File =>
  "c:/Users/Ray/Documents/ex_dev/projects/file_only_logger/generate-line-break"
• App: undefined
• Module: Log
• Function: Check.log_warning/1
```

## Note

If you'd like to write a message to both the log files _and the console_,
simply change the macro to a function like so...

#### Example

```elixir
defmodule Log do
  use File.Only.Logger

  require Logger

  def warning(:error_occurred, {reason, file, env}) do
    Logger.warning("""
    \n'error' occurred...
    Reason => '#{:file.format_error(reason)}'
    File => #{Path.expand(file) |> inspect() |> maybe_break(8)}
    #{from(env, __MODULE__)}\
    """)
  end
end