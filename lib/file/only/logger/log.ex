defmodule File.Only.Logger.Log do
  use File.Only.Logger

  error :handlers, {reason, app, env} do
    """
    \nError adding configured handlers...
    • Call: 'Logger.add_handlers/1'
    • App argument: #{inspect(app)}
    • Reason: #{inspect(reason) |> maybe_break(10)}
    #{from(env, __MODULE__)}\
    """
  end
end
