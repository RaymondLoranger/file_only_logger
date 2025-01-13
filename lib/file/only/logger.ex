defmodule File.Only.Logger do
  @moduledoc """
  A simple logger that writes messages to log files only (not to the console).
  """

  use PersistConfig

  @levels get_env(:levels)

  @doc """
  Either aliases `File.Only.Logger` (this module) and requires the alias or
  imports `File.Only.Logger`. In the latter case, you could instead simply
  `import File.Only.Logger`.

  ## Examples

      use File.Only.Logger, alias: FileLogger

      use File.Only.Logger

      import File.Only.Logger
  """
  defmacro __using__(options) do
    alias = options[:alias]

    if alias do
      quote do
        alias unquote(__MODULE__), as: unquote(alias)
        require unquote(alias)
      end
    else
      quote do
        import unquote(__MODULE__)
      end
    end
  end

  @doc ~S'''
  Injects function `info/2` into the caller's module.

  The function will execute the `do_block` and write its result to the
  configured info log file.

  ## Examples

      use File.Only.Logger

      info :game_state, {player, game} do
        """
        \nNote that #{player.name}...
        • Has joined game #{inspect(game.name)}
        • Game state: #{inspect(game.state)}\
        """
      end
  '''
  defmacro info(message_id, variables, do_block)

  defmacro info(message_id, variables, do: message) do
    quote do
      def info(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:info, unquote(message))
      end
    end
  end

  @doc ~S'''
  Injects function `error/2` into the caller's module.

  The function will execute the `do_block` and write its result to the
  configured error log file.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        Reason => #{inspect(reason)}\
        """
      end
  '''
  defmacro error(message_id, variables, do_block)

  defmacro error(message_id, variables, do: message) do
    quote do
      def error(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:error, unquote(message))
      end
    end
  end

  for level <- @levels -- [:info, :error] do
    defmacro unquote(level)(message_id, variables, do_block)

    defmacro unquote(level)(message_id, variables, do: message) do
      level = unquote(level)

      quote do
        def unquote(level)(unquote(message_id), unquote(variables)) do
          File.Only.Logger.Proxy.log(unquote(level), unquote(message))
        end
      end
    end
  end

  @doc ~S'''
  Returns string "<module>.<function>/<arity>" e.g. "My.Math.sqrt/1" from the
  given `env` (`Macro.Env`).

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • Function: #{fun(env)}\
        """
      end
  '''
  defmacro fun(env) do
    quote do
      File.Only.Logger.Proxy.fun(unquote(env))
    end
  end

  @doc ~S'''
  Will prefix `string` with "\n<padding>" if `string` is longer than
  `<line_length>` - `offset` where `<padding>` and `<line_length>` are
  respectively the `:padding` and `:line_length` options.

  ## Options

    * `:line_length` (positive integer) - the preferred line length of messages
      sent to the log files. Defaults to 80.
    * `:padding` (string) - Filler inserted after the line break. Defaults to
      "\s\s".

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • Function: #{fun(env) |> maybe_break(12)}\
        """
      end
  '''
  defmacro maybe_break(string, offset, options \\ []) do
    string = Macro.expand(string, __CALLER__)

    quote bind_quoted: [string: string, offset: offset, options: options] do
      File.Only.Logger.Proxy.maybe_break(string, offset, options)
    end
  end

  @doc ~S'''
  Returns the application for the current process or module.

  Returns `:undefined` if the current process does not belong to any
  application or the current module is not listed in any application spec.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • App: #{app()}\
        """
      end
  '''
  defmacro app do
    quote do
      File.Only.Logger.Proxy.app(__MODULE__)
    end
  end

  @doc ~S'''
  Returns the current module as a string.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • Module: #{mod()}\
        """
      end
  '''
  defmacro mod do
    quote do
      File.Only.Logger.Proxy.mod(__MODULE__)
    end
  end

  @doc ~S'''
  Returns a formatted heredoc to trace a message from the given `env`
  (`Macro.Env`).

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        #{from(env)}\
        """
      end
  '''
  defmacro from(env) do
    quote do
      File.Only.Logger.Proxy.from(unquote(env))
    end
  end

  @doc ~S'''
  Returns a formatted heredoc to trace a message from the given `env`
  (`Macro.Env`) and `module`.

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        #{from(env, __MODULE__)}\
        """
      end
  '''
  defmacro from(env, module) do
    quote do
      File.Only.Logger.Proxy.from(unquote(env), unquote(module))
    end
  end
end
