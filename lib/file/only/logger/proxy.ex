defmodule File.Only.Logger.Proxy do
  use PersistConfig

  require Logger

  alias File.Only.Logger.Log

  @flush true
  @levels get_env(:levels)
  @lib Mix.Project.config()[:app]
  @limit get_env(:limit)
  @times 7
  @wait 10

  @doc """
  Writes `message` to the configured log file of logging level `level`.
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:info, "*** INFO message ***")
      :ok
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:debug, fn -> "*** DEBUG message ***" end)
      :ok
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:critical, %{critical: :message})
      :ok
  """
  @spec log(Logger.level(), String.t()) :: :ok
  def log(level, message) when level in @levels,
    do: log(level, message, Logger.compare_levels(level, level()))

  @spec fun(Macro.Env.t()) :: String.t()
  def fun(%Macro.Env{function: {name, arity}, module: module}) do
    if to_string(name) |> String.contains?(" "),
      do: "#{inspect(module)}.'#{name}'/#{arity}",
      else: "#{inspect(module)}.#{name}/#{arity}"
  end

  def fun(%Macro.Env{function: nil}), do: "'not inside a function'"

  @spec maybe_break(String.t(), non_neg_integer, pos_integer) :: String.t()
  def maybe_break(string, offset, limit \\ @limit)
      when is_binary(string) and is_integer(offset) and offset >= 0 and
             is_integer(limit) and limit > 0 do
    if String.length(string) > limit - offset, do: "\n  #{string}", else: string
  end

  @spec app :: atom
  def app do
    case :application.get_application() do
      {:ok, app} -> app
      :undefined -> Application.get_application(__MODULE__) || :undefined
    end
  end

  @spec lib :: atom
  def lib, do: @lib

  @spec mod(module) :: String.t()
  def mod(module), do: "#{inspect(module)}"

  @spec from(Macro.Env.t()) :: String.t()
  def from(env) do
    """
    • App: #{app()}
    • Library: #{lib()}
    • Function: #{fun(env) |> maybe_break(12)}
    """
    |> String.trim_trailing()
  end

  @spec from(Macro.Env.t(), module) :: String.t()
  def from(env, module) do
    """
    • App: #{app()}
    • Library: #{lib()}
    • Module: #{mod(module)}
    • Function: #{fun(env) |> maybe_break(12)}
    """
    |> String.trim_trailing()
  end

  ## Private functions

  @spec level :: Logger.level() | :all | :none
  defp level, do: get_env(:level, :all)

  @spec log(Logger.level(), String.t(), :lt | :eq | :gt) :: :ok
  defp log(level, message, compare) when compare in [:gt, :eq] do
    removed =
      case Logger.remove_backend(:console, flush: @flush) do
        :ok ->
          :ok

        {:error, reason} = error ->
          :ok = Log.warn(:unremoved, {@wait, @times, reason, __ENV__})
          retry(error, @times)
      end

    :ok = Logger.log(level, message)
    if removed == :ok, do: Logger.add_backend(:console, flush: @flush)
    :ok
  end

  defp log(_level, _message, _compare), do: :ok

  @spec retry({:error, term}, non_neg_integer) :: :ok | {:error, term}
  defp retry({:error, reason} = error, 0) do
    :ok = Log.warn(:remains_unremoved, {@wait, @times, reason, __ENV__})
    error
  end

  defp retry({:error, reason}, times_left) do
    Process.sleep(@wait)
    times_left = times_left - 1

    case Logger.remove_backend(:console, flush: @flush) do
      :ok ->
        times = @times - times_left
        :ok = Log.warn(:now_removed, {@wait, times, reason, __ENV__})

      {:error, reason} = error ->
        :ok = Log.warn(:still_unremoved, {@wait, times_left, reason, __ENV__})
        retry(error, times_left)
    end
  end
end
