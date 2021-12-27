defmodule File.Only.Logger.Log do
  require Logger

  @spec warn(atom, tuple) :: :ok
  def warn(:unremoved, {wait, times, reason, env}) do
    Logger.warn("""
    \nBackend unremoved on 'Logger.remove_backend/2'...
    • Backend: :console
    • Waiting: #{wait} ms
    • Times left: #{times}
    • Reason: #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:remains_unremoved, {wait, times, reason, env}) do
    Logger.warn("""
    \nBackend remains unremoved...
    • Backend: :console
    • Waited: #{wait} ms
    • Times: #{times}
    • Issue remaining 'unresolved': #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:still_unremoved, {wait, times_left, reason, env}) do
    Logger.warn("""
    \nBackend still unremoved...
    • Backend: :console
    • Waited: #{wait} ms
    • Times left: #{times_left}
    • Issue still 'unresolved': #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:now_removed, {wait, times, reason, env}) do
    Logger.warn("""
    \nBackend now removed...
    • Backend: :console
    • Waited: #{wait} ms
    • Times: #{times}
    • Issue now 'resolved': #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end
end
