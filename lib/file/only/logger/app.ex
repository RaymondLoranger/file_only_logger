defmodule File.Only.Logger.App do
  use Application

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, :ok = _start_args) do
    # Add debug, info, warning and error handlers...
    {Logger.add_handlers(:file_only_logger), self()}
  end
end
