defmodule File.Only.Logger do
  @moduledoc """
  A simple logger which writes messages to log files only (not to the console).
  """

  @fun_limit 66

  # Logging levels ordered by importance or severity...
  @levels [
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
  Injects function `info` into the caller's module.

  The function will write the `message` returned by the `do_block`
  to the configured info log file.

  ## Examples

      use File.Only.Logger

      info :game_state, {player, game} do
        """
        \nNote that #{player.name}...
        • Has joined game #{inspect(game.name)}
        • Game state: #{inspect(game.state)}
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
  Injects function `error` into the caller's module.

  The function will write the `message` returned by the `do_block`
  to the configured error log file.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
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
  Returns string "<module>.<function>/<arity>" e.g. "My.Math.sqrt/1"
  for the given [environment](`Macro.Env`).  A string longer than `limit`
  will be prefixed with "\n\s\s".

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • Function: #{fun(env)}
        """
      end
  '''
  defmacro fun(env, limit \\ @fun_limit) do
    quote do
      File.Only.Logger.Proxy.fun(unquote(env), unquote(limit))
    end
  end

  @doc ~S'''
  Returns the application for the current process or module.

  Returns `:undefined` if the current process does not belong to any application or the current module is not listed in any application spec.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • App: #{app()}
        """
      end
  '''
  defmacro app do
    quote do
      case :application.get_application() do
        {:ok, app} -> app
        :undefined -> Application.get_application(__MODULE__) || :undefined
      end
    end
  end

  @doc ~S'''
  Returns the current library name.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • Library: #{lib()}
        """
      end
  '''
  defmacro lib do
    quote do
      unquote(Mix.Project.config()[:app])
    end
  end

  @doc ~S'''
  Returns the current module name.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n'exit' caught...
        • Reason: #{inspect(reason)}
        • Module: #{mod()}
        """
      end
  '''
  defmacro mod do
    quote do
      "#{inspect(__MODULE__)}"
    end
  end

  @doc ~S'''
  Returns a heredoc to trace the logged message back to its source using the given [environment](`Macro.Env`).

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason:
          #{inspect(reason)}
        #{from(env)}
        """
      end
  '''
  defmacro from(env) do
    quote do
      """
      • App: #{app()}
      • Library: #{lib()}
      • Module: #{mod()}
      • Function: #{fun(unquote(env))}
      """
      |> String.trim_trailing()
    end
  end
end
