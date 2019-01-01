defmodule GenLog do
  use File.Only.Logger

  error :exit, {reason} do
    """
    \n`exit` caught...
    • Reason:
    #{inspect(reason)}
    """
  end

  info :save, {game} do
    """
    \n#{game.name |> via() |> inspect()} #{self() |> inspect()}
    game being saved...
    #{inspect(game, pretty: true)}
    """
  end

  ## Private functions

  defp via(name), do: {:via, Registry, {Server, name}}
end

defmodule File.Only.Logger.IE do
  @moduledoc false

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias File.Only.Logger
      alias File.Only.Logger.Proxy
      :ok
    end
  end

  @spec log_error :: :ok
  def log_error() do
    GenLog.error(:exit, {{:already_started, self() |> inspect()}})
  end

  @spec log_info :: :ok
  def log_info() do
    GenLog.info(:save, {%{name: "blue-moon", state: :exciting}})
  end
end
