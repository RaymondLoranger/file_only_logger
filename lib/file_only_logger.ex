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

  defmacro error(event, variables, do: message) do
    quote do
      def error(unquote(event), unquote(variables)) do
        File.Only.Logger.Proxy.log(:error, unquote(message))
      end
    end
  end
end
