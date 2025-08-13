defmodule File.Only.Logger.App do
  use Application
  use PersistConfig

  alias File.Only.Logger.Log

  @logger_config get_env(:logger)
  @handler_config hd(@logger_config)
  # :debug_handler...
  @handler_id elem(@handler_config, 1)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    if @handler_id not in :logger.get_handler_ids() do
      add_handlers(:file_only_logger)
    end

    {:ok, self()}
  end

  ## Private functions

  # Add debug, info, warning and error handlers...
  # Returns :ok or {:error, term} where term would likely be:
  # {:bad_config, {:handler, {:file_only_logger, {:already_exist, _id}}}}
  @spec add_handlers(Application.app()) :: :ok
  defp add_handlers(app) do
    case Logger.add_handlers(app) do
      :ok -> :ok
      {:error, reason} -> :ok = Log.error(:handlers, {reason, app, __ENV__})
    end
  end
end
