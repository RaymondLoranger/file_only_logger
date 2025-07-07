defmodule File.Only.Logger.App do
  use Application

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    # Prevent console messages...
    :ok = :logger.set_handler_config(:default, :level, :none)

    # Add debug, info, warning and error handlers...
    Logger.add_handlers(:file_only_logger)
    # Returns :ok or {:error, term} where term would likely be:
    # {:bad_config, {:handler, {:file_only_logger, {:already_exist, _id}}}}

    # Allow console messages...
    :ok = :logger.set_handler_config(:default, :level, Logger.level())

    {:ok, self()}
  end
end
