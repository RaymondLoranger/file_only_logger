defmodule File.Only.Logger.IE.Log do
  @moduledoc false

  use File.Only.Logger

  error :exit, {reason} do
    """
    \n'exit' caught...
    • Reason:
      #{inspect(reason)}
    """
  end

  info :save, {game} do
    """
    \nSaving game...
    • Server:
      #{game.name |> via() |> inspect()}
    • Game being saved:
      #{inspect(game)}
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
  #   log_error # And then check log files
  #   log_info # And then check log files

  alias __MODULE__.Log

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias unquote(__MODULE__).Log
      alias File.Only.Logger.Proxy
      alias File.Only.Logger
      :ok
    end
  end

  @spec log_error :: :ok
  def log_error() do
    Log.error(:exit, {{:already_started, self() |> inspect()}})
  end

  @spec log_info :: :ok
  def log_info() do
    Log.info(:save, {%{name: "blue-moon", state: :exciting}})
  end
end
