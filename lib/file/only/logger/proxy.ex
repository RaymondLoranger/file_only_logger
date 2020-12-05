defmodule File.Only.Logger.Proxy do
  use PersistConfig

  require Logger

  @spec log(Logger.level(), String.t()) :: :ok
  def log(level, message), do: log(level, message, log?())

  ## Private functions

  @spec log? :: boolean
  defp log?, do: get_env(:log?, true)

  @spec log(Logger.level(), String.t(), boolean) :: :ok
  defp log(level, message, true = _log?) do
    removed = Logger.remove_backend(:console, flush: false)
    Logger.log(level, message)
    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end

  defp log(_level, _message, _log?), do: :ok
end
