defmodule File.Only.Logger.Log do
  use PersistConfig

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

  def warn(:remains_unremoved, {wait, times, env}) do
    Logger.warn("""
    \nBackend remains unremoved...
    • Backend: :console
    • Waited: #{wait} ms
    • Times: #{times}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:still_unremoved, {wait, times_left, reason, env}) do
    Logger.warn("""
    \nBackend still unremoved...
    • Backend: :console
    • Waited: #{wait} ms
    • Times left: #{times_left}
    • Reason: #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:now_removed, {wait, times, env}) do
    Logger.warn("""
    \nBackend now removed...
    • Backend: :console
    • Waited: #{wait} ms
    • Times: #{times}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:unadded, {wait, times, reason, env}) do
    Logger.warn("""
    \nBackend unadded on 'Logger.add_backend/2'...
    • Backend: :console
    • Waiting: #{wait} ms
    • Times left: #{times}
    • Reason: #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:remains_unadded, {wait, times, env}) do
    Logger.warn("""
    \nBackend remains unadded...
    • Backend: :console
    • Waited: #{wait} ms
    • Times: #{times}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:still_unadded, {wait, times_left, reason, env}) do
    Logger.warn("""
    \nBackend still unadded...
    • Backend: :console
    • Waited: #{wait} ms
    • Times left: #{times_left}
    • Reason: #{inspect(reason)}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end

  def warn(:now_added, {wait, times, env}) do
    Logger.warn("""
    \nBackend now added...
    • Backend: :console
    • Waited: #{wait} ms
    • Times: #{times}
    #{File.Only.Logger.Proxy.from(env, __MODULE__)}
    """)
  end
end
