defmodule File.Only.Logger.Agent do
  use PersistConfig

  require Logger

  @spec log(atom, String.t()) :: :ok
  def log(level, message), do: log(level, message, log?())

  ## Private functions

  @spec log? :: boolean
  defp log?, do: Application.get_env(@app, :log?, false)

  @spec log(atom, String.t(), boolean) :: :ok
  defp log(_level, _message, false = _log?), do: :ok

  defp log(level, message, true = _log?) do
    removed = Logger.remove_backend(:console, flush: true)
    Logger.log(level, message)
    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end
end
