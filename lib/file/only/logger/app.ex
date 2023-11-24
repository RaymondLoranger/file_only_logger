defmodule File.Only.Logger.App do
  use Application

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, :ok = _start_args) do
    # Add debug, info, warning and error handlers...
    case Logger.add_handlers(:file_only_logger) do
      :ok ->
        {:ok, self()}

      # Possibly due to compile time configuration in map_sorter...
      {:error,
       {:bad_config, {:handler, {:file_only_logger, {:already_exist, _id}}}}} ->
        {:ok, self()}
    end
  end
end
