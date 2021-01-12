defmodule File.Only.Logger do
  @moduledoc """
  A simple logger which writes messages to log files only (not to the console).
  """

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

  defmacro debug(message_id, variables, do_block)

  defmacro debug(message_id, variables, do: message) do
    quote do
      def debug(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:debug, unquote(message))
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

  defmacro notice(message_id, variables, do_block)

  defmacro notice(message_id, variables, do: message) do
    quote do
      def notice(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:notice, unquote(message))
      end
    end
  end

  defmacro warning(message_id, variables, do_block)

  defmacro warning(message_id, variables, do: message) do
    quote do
      def warning(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:warning, unquote(message))
      end
    end
  end

  defmacro warn(message_id, variables, do_block)

  defmacro warn(message_id, variables, do: message) do
    quote do
      def warn(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:warn, unquote(message))
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
        • Reason:
          #{inspect(reason)}
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

  defmacro critical(message_id, variables, do_block)

  defmacro critical(message_id, variables, do: message) do
    quote do
      def critical(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:critical, unquote(message))
      end
    end
  end

  defmacro alert(message_id, variables, do_block)

  defmacro alert(message_id, variables, do: message) do
    quote do
      def alert(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:alert, unquote(message))
      end
    end
  end

  defmacro emergency(message_id, variables, do_block)

  defmacro emergency(message_id, variables, do: message) do
    quote do
      def emergency(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:emergency, unquote(message))
      end
    end
  end

  @doc ~S'''
  Returns string "<module>.<function>/<arity>" e.g. "My.Math.sqrt/1"
  for the given [environment](`Macro.Env`).

  ## Examples

      use File.Only.Logger

      error :exit, {reason, env} do
        """
        \n'exit' caught...
        • Reason:
          #{inspect(reason)}
        • Inside function:
          #{fun(env)}
        """
      end
  '''
  defmacro fun(env) do
    quote bind_quoted: [env: env] do
      case env do
        %Macro.Env{function: {name, arity}} ->
          if to_string(name) |> String.contains?(" "),
            do: "#{inspect(env.module)}.'#{name}'/#{arity}",
            else: "#{inspect(env.module)}.#{name}/#{arity}"

        %Macro.Env{function: nil} ->
          "'not inside a function'"
      end
    end
  end

  defmacro app do
    quote do
      case :application.get_application() do
        {:ok, app} -> app
        :undefined -> :undefined
      end
    end
  end

  defmacro lib do
    quote do
      unquote(Mix.Project.config()[:app])
    end
  end

  defmacro mod do
    quote do
      "#{inspect(__MODULE__)}"
    end
  end

  defmacro from do
    quote do
      """
      • App: #{app()}
      • Library: #{lib()}
      • Module: #{mod()}
      """
      |> String.trim_trailing()
    end
  end
end
