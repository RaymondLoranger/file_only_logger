defmodule File.Only.Logger.App do
  use Application
  use PersistConfig

  alias File.Only.Logger.Log

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    case Logger.add_handlers(@app) do
      :ok -> :ok
      {:error, reason} -> :ok = Log.error(:handlers, {reason, @app, __ENV__})
    end

    {:ok, self()}
  end
end
