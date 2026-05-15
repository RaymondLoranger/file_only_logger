defmodule File.Only.Logger.Log do
  use File.Only.Logger

  require Logger

  # Log to both log files and console...

  @spec error(atom, tuple) :: :ok
  def error(:add_handler, {reason, handler_id, env}) do
    Logger.error("""
    \nError adding logger handler...
    • Handler id: #{inspect(handler_id)}
    • Call: ':logger.add_handler/3'
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}\
    """)
  end

  def error(:upd_config, {reason, handler_id, env}) do
    Logger.error("""
    \nError updating logger handler config...
    • Handler id: #{inspect(handler_id)}
    • Call: ':logger.update_handler_config/3'
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}\
    """)
  end

  def error(:handlers, {reason, app, env}) do
    Logger.error("""
    \nError adding configured handlers...
    • Call: 'Logger.add_handlers/1'
    • App argument: #{inspect(app)}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}\
    """)
  end
end
