defmodule File.Only.Logger.App do
  use Application
  use PersistConfig

  alias File.Only.Logger.Log

  @format get_env(:format) |> dbg()
  @truncate_in_bytes get_env(:truncate_default_in_bytes)
  @config get_env(:config)
  @colors get_env(:colors)

  @root_dir File.cwd!() |> dbg()
  @debug_path ~c"#{@root_dir}/log/debug.log" |> dbg()
  @info_path ~c"#{@root_dir}/log/info.log" |> dbg()
  @warning_path ~c"#{@root_dir}/log/warning.log" |> dbg()
  @error_path ~c"#{@root_dir}/log/error.log" |> dbg()

  @formatter Logger.Formatter.new(
               format: @format,
               # Prevents ANSI escape sequences in log files.
               colors: [enabled: false],
               truncate: @truncate_in_bytes
             )
             |> dbg()
  @default_formatter Logger.default_formatter(
                       format: @format,
                       colors: @colors,
                       truncate: @truncate_in_bytes
                     )
                     |> dbg()

  @debug_config %{
                  level: :debug,
                  config: %{@config | file: @debug_path},
                  formatter: @formatter
                }
                |> dbg()
  @info_config %{
                 level: :info,
                 config: %{@config | file: @info_path},
                 formatter: @formatter
               }
               |> dbg()
  @warning_config %{
                    level: :warning,
                    config: %{@config | file: @warning_path},
                    formatter: @formatter
                  }
                  |> dbg()
  @error_config %{
                  level: :error,
                  config: %{@config | file: @error_path},
                  formatter: @formatter
                }
                |> dbg()

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, _start_args = :ok) do
    :logger.update_handler_config(:default, :formatter, @default_formatter)

    :logger.add_handler(:debug_handler, :logger_std_h, @debug_config)
    :logger.add_handler(:info_handler, :logger_std_h, @info_config)
    :logger.add_handler(:warning_handler, :logger_std_h, @warning_config)
    :logger.add_handler(:error_handler, :logger_std_h, @error_config)

    :logger.get_handler_config(:debug_handler) |> dbg()
    :logger.get_handler_config(:error_handler) |> dbg()
    :logger.get_handler_config(:default) |> dbg()
    {:ok, self()}
  end
end
