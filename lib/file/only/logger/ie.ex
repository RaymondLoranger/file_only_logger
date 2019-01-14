defmodule GenLog do
  @moduledoc false

  use File.Only.Logger

  error :exit, {reason} do
    """
    \n'exit' caught...
    • Reason:
      #{inspect(reason, pretty: true)}
    """
  end

  info :save, {game} do
    """
    \nSaving game...
    • Server:
      #{game.name |> via() |> inspect(pretty: true)}
    • Game being saved:
      #{inspect(game, pretty: true)}
    """
  end

  ## Private functions

  defp via(name), do: {:via, Registry, {:registry, {Server, name}}}
end

defmodule File.Only.Logger.IE do
  @moduledoc false

  # Example of an IEx session...
  #
  #   iex -S mix
  #
  #   use File.Only.Logger.IE
  #   log_error # check log files
  #   log_info # check log files

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias File.Only.Logger.Agent
      alias File.Only.Logger
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
