defmodule File.Only.Logger.Proxy do
  use PersistConfig

  require Logger

  @spec log(Logger.level(), String.t()) :: :ok
  def log(level, message),
    do: log(level, message, Logger.compare_levels(level, level()))

  @spec fun(Macro.Env.t(), integer | :infinity) :: String.t()
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

  @spec level :: Logger.level() | :all | :none
  defp level, do: get_env(:level, :all)

  @spec log(Logger.level(), String.t(), :lt | :eq | :gt) :: :ok
  defp log(level, message, compare) when compare in [:gt, :eq] do
    removed =
      case Logger.remove_backend(:console, flush: true) do
        :ok -> :ok
        error -> log(error)
      end

    :ok = Logger.log(level, message)
    if removed == :ok, do: Logger.add_backend(:console, flush: true)
    :ok
  end

  defp log(_level, _message, _compare), do: :ok

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
