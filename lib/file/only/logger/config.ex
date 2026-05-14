defmodule File.Only.Logger.Config do
  use PersistConfig

  alias File.Only.Logger.Log

  @format get_env(:format)
  @truncate_in_bytes get_env(:truncate_default_in_bytes)
  @config get_env(:config)
  @colors get_env(:colors)
  @formatter Logger.Formatter.new(
               format: @format,
               # Prevents ANSI escape sequences in log files.
               colors: [enabled: false],
               truncate: @truncate_in_bytes
             )
  @default_formatter Logger.default_formatter(
                       format: @format,
                       colors: @colors,
                       truncate: @truncate_in_bytes
                     )

  defmacro update_handler_config(handler_id) do
    formatter = Macro.escape(@default_formatter)

    quote bind_quoted: [id: handler_id, formatter: formatter] do
      case :logger.update_handler_config(id, :formatter, formatter) do
        :ok -> :ok
        {:error, reason} -> :ok = Log.error(:upd_config, {reason, id, __ENV__})
      end
    end
  end

  defmacro add_handler(level) do
    # Relative to wherever the BEAM (Erlang VM) was started...
    path = ~c"./log/#{level}.log"
    config = %{@config | file: path}
    config = %{level: level, config: config, formatter: @formatter}
    config = Macro.escape(config)
    handler_id = :"#{level}_handler"

    quote bind_quoted: [id: handler_id, config: config] do
      case :logger.add_handler(id, :logger_std_h, config) do
        :ok -> :ok
        {:error, reason} -> :ok = Log.error(:add_handler, {reason, id, __ENV__})
      end
    end
  end

  defmacro standard_formatter?(handler_id) do
    template = ["\n", :time, " ", :metadata, "[", :level, "] ", :message, "\n"]

    quote bind_quoted: [handler_id: handler_id, template: template] do
      case :logger.get_handler_config(handler_id) do
        {:ok,
         %{
           formatter:
             {Logger.Formatter,
              %Logger.Formatter{template: template, colors: %{error: :red}}}
         }} ->
          true

        _else ->
          false
      end
    end
  end

  defmacro add_handlers(app) do
    quote bind_quoted: [app: app] do
      case Logger.add_handlers(app) do
        :ok -> :ok
        {:error, reason} -> :ok = Log.error(:handlers, {reason, app, __ENV__})
      end
    end
  end
end
