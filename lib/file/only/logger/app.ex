defmodule File.Only.Logger.App do
  use Application
  use PersistConfig

  import File.Only.Logger.Config

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    # Remove log files...
    # File.rm_rf("log")
    # ┌─────────────────────────────────┐
    # │ Runtime logger configuration... │
    # └─────────────────────────────────┘
    if standard_formatter?(:default), do: update_handler_config(:default)

    if get_env(:logger) do
      add_handlers(@app)
    else
      add_handler(:debug)
      add_handler(:info)
      add_handler(:warning)
      add_handler(:error)
      # Force error logging...
      # add_handler(:error)
    end

    {:ok, self()}
  end
end
