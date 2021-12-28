defmodule File.Only.Logger.DeleteLogFiles do
  def __after_compile__(_env, _bytecode) do
    if File.cwd!() |> String.ends_with?("#{Mix.Project.config()[:app]}") do
      # %{debug: "./log/debug.log", info: "./log/info.log", ...}
      paths = %{
        debug: Application.get_env(:logger, :debug_log)[:path],
        info: Application.get_env(:logger, :info_log)[:path],
        warn: Application.get_env(:logger, :warn_log)[:path],
        error: Application.get_env(:logger, :error_log)[:path]
      }

      # Delete each log file...
      paths
      |> Map.values()
      |> Enum.reject(&is_nil/1)
      |> Enum.each(&File.rm/1)
    end
  end
end
