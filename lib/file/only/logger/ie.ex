defmodule File.Only.Logger.IE.Log do
  @moduledoc false

  use File.Only.Logger

  error :exit, {reason, env} do
    """
    \n'exit' caught...
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env)}
    """
  end

  info :save, {game, env} do
    """
    \nSaving game...
    • Server: #{via(game.name) |> inspect() |> maybe_break(10)}
    • Game being saved: #{inspect(game) |> maybe_break(20)}
    #{from(env, __MODULE__)}
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
      import File.Only.Logger

      alias unquote(__MODULE__)
      alias unquote(__MODULE__).Log
      alias File.Only.Logger.Log
      alias File.Only.Logger.Proxy
      alias File.Only.Logger

      :ok
    end
  end

  @spec log_error :: :ok
  def log_error do
    Log.error(:exit, {{:already_started, self()}, __ENV__})
  end

  @spec log_info :: :ok
  def log_info do
    Log.info(:save, {%{name: "blue-moon", state: :exciting}, __ENV__})
    game = %{name: "supercalifragilisticexpialidocious", state: :extremely_good}
    Log.info(:save, {game, __ENV__})
  end
end
