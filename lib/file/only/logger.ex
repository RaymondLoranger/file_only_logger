defmodule File.Only.Logger do
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

  defmacro debug(message_id, variables, do: message) do
    quote do
      def debug(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:debug, unquote(message))
      end
    end
  end

  @doc ~S'''
  Injects function `info` within the caller's context.

  The function will write a `message` to the configured info log file.

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
  defmacro info(message_id, variables, do: message) do
    quote do
      def info(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:info, unquote(message))
      end
    end
  end

  defmacro warn(message_id, variables, do: message) do
    quote do
      def warn(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:warn, unquote(message))
      end
    end
  end

  @doc ~S'''
  Injects function `error` within the caller's context.

  The function will write a `message` to the configured error log file.

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
  defmacro error(message_id, variables, do: message) do
    quote do
      def error(unquote(message_id), unquote(variables)) do
        File.Only.Logger.Proxy.log(:error, unquote(message))
      end
    end
  end

  @spec app :: atom
  def app do
    case :application.get_application() do
      {:ok, app} -> app
      :undefined -> :undefined
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
