defmodule File.Only.Logger.Proxy do
  @moduledoc """
  Implements logging messages to files only (not to the console).
  """

  use PersistConfig

  require Logger

  @levels get_env(:levels)
  @lib Mix.Project.config()[:app]
  @line_length get_env(:line_length)
  @padding get_env(:padding)

  @typedoc "Message to be logged"
  @type message :: String.t() | iodata | fun | keyword | map

  @doc """
  Returns `true` if `value` is a positive integer, otherwise `false`.
  """
  defguard is_pos_integer(value) when is_integer(value) and value > 0

  @doc """
  Writes `message` to the configured log file of logging level `level`.

  ## Examples

      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:debug, "*** String message ***")
      :ok

      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:debug, ['*** Improper ', 'List ' | 'Message ***'])
      :ok

      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:debug, fn -> "*** Function message ***" end)
      :ok

      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:debug, %{'first' => 'Map', 'last' => 'Message'})
      :ok

      iex> alias File.Only.Logger.Proxy
      iex> Proxy.log(:debug, first: 'Keyword', last: 'Message')
      :ok
  """
  @spec log(Logger.level(), message) :: :ok
  def log(level, message) when level in @levels do
    Logger.configure(level: level())
    Logger.configure_backend(:console, level: :none)
    :ok = Logger.log(level, message)
    Logger.configure_backend(:console, level: Logger.level())
    :ok
  end

  @doc """
  Returns string "<module>.<function>/<arity>" e.g. "My.Math.sqrt/1" from the
  given `env` (`Macro.Env`).

  ## Examples

      iex> defmodule My.Math do
      iex>   alias File.Only.Logger.Proxy
      iex>   def sqrt(_number) do
      iex>     Proxy.fun(__ENV__)
      iex>   end
      iex> end
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
  Will prefix `string` with "\n<padding>" if `string` is longer than
  `<line_length>` - `offset` where `<padding>` and `<line_length>` are
  respectively the `:padding` and `:line_length` options.

  ## Options

    * `:line_length` (positive integer) - the preferred line length of messages
      sent to the log files. Defaults to 80.
    * `:padding` (string) - Filler inserted after the line break. Defaults to
      "\s\s".

  ## Examples

      iex> alias File.Only.Logger.Proxy
      iex> supercal = 'supercalifragilisticexpialidocious'
      iex> """
      ...> • Feeling: #{inspect(supercal) |> Proxy.maybe_break(11)}
      ...> """
      """
      • Feeling: 'supercalifragilisticexpialidocious'
      """

      iex> alias File.Only.Logger.Proxy
      iex> supercal = "supercalifragilisticexpialidocious"
      iex> supercal! = "#{supercal}ly #{supercal}!"
      iex> """
      ...> • Feeling: #{String.capitalize(supercal!) |> Proxy.maybe_break(11)}
      ...> """
      """
      • Feeling:\s
        Supercalifragilisticexpialidociously supercalifragilisticexpialidocious!
      """

      iex> import File.Only.Logger.Proxy, only: [maybe_break: 3]
      iex> supercal = 'supercalifragilisticexpialidocious'
      iex> msg = "Today I'm feeling astonishingly #{supercal}..."
      iex> """
      ...> -- Message: #{inspect(msg) |> maybe_break(12, padding: "\s\s\s")}
      ...> """
      """
      -- Message:\s
         "Today I'm feeling astonishingly supercalifragilisticexpialidocious..."
      """
  '''
  @spec maybe_break(String.t(), pos_integer, keyword) :: String.t()
  def maybe_break(string, offset, options \\ [])
      when is_binary(string) and is_pos_integer(offset) and is_list(options) do
    line_length =
      case options[:line_length] do
        length when is_pos_integer(length) -> length
        _other -> @line_length
      end

    padding =
      case options[:padding] do
        filler when is_binary(filler) -> filler
        _other -> @padding
      end

    if String.length(string) > line_length - offset,
      do: "\n#{padding}#{string}",
      else: string
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
  Returns a formatted heredoc to trace a message from the given `env`
  (`Macro.Env`).

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
  Returns a formatted heredoc to trace a message from the given `env`
  (`Macro.Env`) and `module`.

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
end
