defmodule File.Only.Logger.App do
  use Application

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, :ok = _start_args) do
    # Prevent console messages...
    :logger.set_handler_config(:default, :level, :none)

    # Add debug, info, warning and error handlers...
    case Logger.add_handlers(:file_only_logger) do
      :ok ->
        # Allow console messages...
        :ok = :logger.set_handler_config(:default, :level, Logger.level())
        {:ok, self()}

      # Likely due to compile time configuration in map_sorter...
      # Will log error message ==> Invalid logger handler config:
      # {:file_only_logger, {:already_exist, :debug_handler}}
      {:error,
       {:bad_config, {:handler, {:file_only_logger, {:already_exist, _id}}}}} ->
        # Allow console messages...
        :ok = :logger.set_handler_config(:default, :level, Logger.level())
        {:ok, self()}
    end
  end
end
