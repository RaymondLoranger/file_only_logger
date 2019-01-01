defmodule File.Only.Logger do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro debug(event, variables, do: message) do
    quote do
      def debug(unquote(event), unquote(variables)) do
        File.Only.Logger.Proxy.log(:debug, unquote(message))
      end
    end
  end

  @doc ~S'''
  Injects function `info` within the caller's context.

  This function will write a formatted message to the configured info log file.

  ## Examples

      use File.Only.Logger

      info :game_state, {player, game} do
        """
        \nNote that #{player.name}:
        • Has joined game #{inspect(game.name)}
        • Game state: #{inspect(game.state)}
        """
      end
  '''
  defmacro info(event, variables, do: message) do
    quote do
      def info(unquote(event), unquote(variables)) do
        File.Only.Logger.Proxy.log(:info, unquote(message))
      end
    end
  end

  defmacro warn(event, variables, do: message) do
    quote do
      def warn(unquote(event), unquote(variables)) do
        File.Only.Logger.Proxy.log(:warn, unquote(message))
      end
    end
  end

  @doc ~S'''
  Injects function `error` within the caller's context.

  This function will write a formatted message to the configured error log file.

  ## Examples

      use File.Only.Logger

      error :exit, {reason} do
        """
        \n`exit` caught...
        • Reason:
        #{inspect(reason)}
        """
      end
  '''
  defmacro error(event, variables, do: message) do
    quote do
      def error(unquote(event), unquote(variables)) do
        File.Only.Logger.Proxy.log(:error, unquote(message))
      end
    end
  end
end
