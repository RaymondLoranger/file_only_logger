# File-Only Logger

A simple logger which writes messages to log files only (not to the console).

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

You can use file `config/runtime.exs` to prevent file logging:

```elixir
import Config

config :file_only_logger, log?: false
```

#### Example

```elixir
defmodule Log do
  use File.Only.Logger

  error :error_occurred, {reason} do
    """
    \n'error' occurred...
    • Reason:
      '#{:file.format_error(reason)}'
    """
  end
end

defmodule Check do
  def log_error() do
    Log.error(:error_occurred, {:enoent})
  end
end
```
