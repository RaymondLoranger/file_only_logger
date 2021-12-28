defmodule File.Only.Logger.Proxy do
  @moduledoc """
  Implements logging messages to files only (not to the console).
  """

  use PersistConfig

  require Logger

  alias __MODULE__.Try

  @after_compile get_env(:after_compile)
  @levels get_env(:levels)
  @lib Mix.Project.config()[:app]
  @limit get_env(:limit)

  @doc """
  Returns `true` if `value` is a positive integer, otherwise `false`.
  """
  defguard is_pos_int(value) when is_integer(value) and value > 0

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

  @doc """
  Returns string "<module>.<function>/<arity>" e.g. "My.Math.sqrt/1" from the
  given `env` (`Macro.Env`).
  
  ## Examples
  
      iex> defmodule My.Math do
      ...>   alias File.Only.Logger.Proxy
      ...>   def sqrt(_number) do
      ...>     Proxy.fun(__ENV__)
      ...>   end
      ...> end
      iex> My.Math.sqrt(9)
      "File.Only.Logger.ProxyTest.My.Math.sqrt/1"
  """
  @spec fun(Macro.Env.t()) :: String.t()
  def fun(%Macro.Env{function: {name, arity}, module: module} = _env) do
    if to_string(name) |> String.contains?(" "),
      do: "#{inspect(module)}.'#{name}'/#{arity}",
      else: "#{inspect(module)}.#{name}/#{arity}"
  end

  def fun(%Macro.Env{function: nil}), do: "'not inside a function'"

  @doc ~S'''
  May prefix `string` with "\n\s\s" if longer than `limit` - `offset`.
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> supercal = "supercalifragilisticexpialidocious"
      iex> heredoc = """
      ...> Feeling: #{supercal}
      ...> """
      iex> Proxy.maybe_break(heredoc, 9)
      "Feeling: supercalifragilisticexpialidocious\n"
  
      iex> alias File.Only.Logger.Proxy
      iex> supercal = "supercalifragilisticexpialidocious"
      iex> heredoc = """
      ...> Feeling: #{supercal}ly #{supercal}
      ...> """
      iex> Proxy.maybe_break(heredoc, 9) |> String.starts_with?("\n\s\sFeeling")
      true
  '''
  @spec maybe_break(String.t(), pos_integer, pos_integer) :: String.t()
  def maybe_break(string, offset, limit \\ @limit)
      when is_binary(string) and is_pos_int(offset) and is_pos_int(limit) do
    if String.length(string) > limit - offset, do: "\n  #{string}", else: string
  end

  @doc """
  Returns the application for the current process or module.
  
  Returns `:undefined` if the current process does not belong to any
  application or the current module is not listed in any application spec.
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.app
      :file_only_logger
  """
  @spec app :: atom
  def app do
    case :application.get_application() do
      {:ok, app} -> app
      :undefined -> Application.get_application(__MODULE__) || :undefined
    end
  end

  @doc """
  Returns the current library name.
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.lib
      :file_only_logger
  """
  @spec lib :: atom
  def lib, do: @lib

  @doc """
  Returns the given `module` as a string.
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.mod(__MODULE__)
      "File.Only.Logger.ProxyTest"
  
      iex> alias File.Only.Logger.Proxy
      iex> Proxy.mod(Elixir.Date.Range)
      "Date.Range"
  """
  @spec mod(module) :: String.t()
  def mod(module), do: inspect(module)

  @doc ~S'''
  Returns a formatted heredoc to trace a message given `env` (`Macro.Env`).
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> heredoc = """
      ...> • App: file_only_logger
      ...> • Library: file_only_logger
      ...> • Function:\s
      ...>   File.Only.Logger.ProxyTest.
      ...> """
      ...> |> String.trim_trailing()
      iex> Proxy.from(__ENV__) =~ heredoc
      true
  '''
  @spec from(Macro.Env.t()) :: String.t()
  def from(env) do
    """
    • App: #{app()}
    • Library: #{lib()}
    • Function: #{fun(env) |> maybe_break(12)}
    """
    |> String.trim_trailing()
  end

  @doc ~S'''
  Returns a formatted heredoc to trace a message given `env` (`Macro.Env`) and
  `module`.
  
  ## Examples
  
      iex> alias File.Only.Logger.Proxy
      iex> heredoc = """
      ...> • App: file_only_logger
      ...> • Library: file_only_logger
      ...> • Module: File.Only.Logger.ProxyTest
      ...> • Function:\s
      ...>   File.Only.Logger.ProxyTest.
      ...> """
      ...> |> String.trim_trailing()
      iex> Proxy.from(__ENV__, __MODULE__) =~ heredoc
      true
  '''
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
    removed = Try.remove_backend()
    :ok = Logger.log(level, message)
    if removed == :ok, do: Try.add_backend()
    :ok
  end

  defp log(_level, _message, _compare), do: :ok
end
