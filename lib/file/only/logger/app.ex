defmodule File.Only.Logger.App do
  use Application

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    # dbg_handler_config("Before preventing console messages...", __ENV__)
    # Prevent console messages...
    :ok = :logger.set_handler_config(:default, :level, :none)
    # dbg_handler_config("After preventing console messages...", __ENV__)
    # Add debug, info, warning and error handlers...
    case Logger.add_handlers(:file_only_logger) do
      :ok ->
        # Allow console messages...
        :ok = :logger.set_handler_config(:default, :level, Logger.level())
        # dbg_handler_config("After allowing console messages...", __ENV__)
        {:ok, self()}

      # Likely due to compile time configuration in map_sorter...
      # Will log error message ==> Invalid logger handler config:
      # {:file_only_logger, {:already_exist, :debug_handler}}
      {:error,
       {:bad_config, {:handler, {:file_only_logger, {:already_exist, _id}}}}} ->
        # Allow console messages...
        :ok = :logger.set_handler_config(:default, :level, Logger.level())
        # dbg_handler_config("After allowing console messages...", __ENV__)
        {:ok, self()}
    end
  end

  ## Private functions

  # defp get_handler_config(id, color) do
  #   case :logger.get_handler_config(id) do
  #     {:ok, %{config: %{type: :file, file: file}, level: _level}} ->
  #       file

  #     {:ok,
  #      %{
  #        config: %{type: :standard_io},
  #        level: level,
  #        formatter: {Logger.Formatter, %Logger.Formatter{colors: colors}}
  #      }} ->
  #       {id, level, colors[color]}

  #     {:error, {:not_found, ^id} = error} ->
  #       error
  #   end
  # end

  # @sep "==========================================================="
  # @cyan "\e[36m"
  # @light_cyan "\e[96m"
  # @reset "\e[0m"

  # defp dbg_handler_config(msg, env) do
  #   """
  #   #{@cyan}#{@sep}
  #   #{@light_cyan}#{msg}
  #   #{inspect(env.module)}.#{inspect(env.function)}:#{env.line}
  #   #{get_handler_config(:debug_handler, :debug) |> inspect()}
  #   #{get_handler_config(:default, :debug) |> inspect()}
  #   #{@cyan}#{@sep}#{@reset}
  #   """
  #   |> IO.puts()
  # end
end
