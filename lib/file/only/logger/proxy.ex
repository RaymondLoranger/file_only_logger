defmodule File.Only.Logger.Proxy do
  use PersistConfig

  require Logger

  @spec log(Logger.level(), String.t()) :: :ok
  def log(level, message), do: log(level, message, log?())

  @spec fun(Macro.Env.t(), :infinity | integer) :: String.t()
  def fun(%Macro.Env{} = env, limit)
      when is_integer(limit) or limit == :infinity do
    fun = fun(env)
    if String.length(fun) > limit, do: "\n  #{fun}", else: fun
  end

  ## Private functions

  @spec fun(Macro.Env.t()) :: String.t()
  defp fun(%Macro.Env{function: {name, arity}, module: module}) do
    if to_string(name) |> String.contains?(" "),
      do: "#{inspect(module)}.'#{name}'/#{arity}",
      else: "#{inspect(module)}.#{name}/#{arity}"
  end

  defp fun(%Macro.Env{function: nil}), do: "'not inside a function'"

  @spec log? :: boolean
  defp log?, do: get_env(:log?, true)

  @spec log(Logger.level(), String.t(), boolean) :: :ok
  defp log(level, message, true = _log?) do
    removed =
      case Logger.remove_backend(:console, flush: true) do
        :ok -> :ok
        error -> log(error)
      end

    :ok = Logger.log(level, message)
    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end

  defp log(_level, _message, _log?), do: :ok

  @spec log(tuple) :: tuple
  defp log({:error, term} = error) do
    Logger.error("""
    \nError calling 'Logger.remove_backend/2':
    • Error:
      #{inspect(term)}
    """)

    error
  end
end
