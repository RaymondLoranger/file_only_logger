defmodule File.Only.LoggerTest.Log do
  use File.Only.Logger

  def message(logged_as, no_longer_as, env) do
    """
    \nActual '#{logged_as}' message no longer reported as '#{no_longer_as}'...
    • Logged as: '#{logged_as}'
    • No longer reported as: '#{no_longer_as}'
    #{from(env, __MODULE__)}\
    """
  end

  notice :message, {logged_as, no_longer_as, env} do
    message(logged_as, no_longer_as, env)
  end

  warning :message, {logged_as, no_longer_as, env} do
    message(logged_as, no_longer_as, env)
  end

  critical :message, {logged_as, no_longer_as, env} do
    message(logged_as, no_longer_as, env)
  end

  alert :message, {logged_as, no_longer_as, env} do
    message(logged_as, no_longer_as, env)
  end

  emergency :message, {logged_as, no_longer_as, env} do
    message(logged_as, no_longer_as, env)
  end

  info :joined_game, {player, game, env} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    #{from(env, __MODULE__)}\
    """
  end

  info :joined_game_also, {player, game} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    • App: #{app()}
    • Library: #{lib()}
    • Module: #{mod()}\
    """
  end

  info :all_env, {app, all_env} do
    """
    \nApplication environment:
    • For app: #{app}
    • Key-value pairs:
      #{inspect(all_env)}\
    """
  end

  info :binary_break, {env} do
    """
    \nChecking line break with binary arg:
    • Relative path: #{Path.relative_to_cwd(env.file) |> maybe_break(17)}
    • Absolute path: #{Path.expand(env.file) |> maybe_break(17)}\
    """
  end
end

defmodule File.Only.LoggerTest do
  use ExUnit.Case, async: true
  use PersistConfig

  require Logger

  alias __MODULE__.Log

  @env get_env(:env)
  @test_wait get_env(:test_wait)

  doctest Logger

  setup_all do
    anthony = %{name: "Anthony", points: 43}
    stephan = %{name: "Stephan", points: 34}
    raymond = %{name: "Raymond", points: 56}

    anthony = %{name: ANTHONY, state: :on_going, player: anthony}
    stephan = %{name: STEPHAN, state: :starting, player: stephan}
    raymond = %{name: RAYMOND, state: :stopping, player: raymond}

    games = %{anthony: anthony, stephan: stephan, raymond: raymond}

    # %{debug: "./log/debug.log", info: "./log/info.log", ...}
    paths =
      for {:handler, _handler_id, :logger_std_h,
           %{level: level, config: %{file: path}}} <-
            get_app_env(:file_only_logger, :logger, []),
          into: %{},
          do: {level, path}

    %{games: games, paths: paths}
  end

  describe "Log.notice/2" do
    test "logs a notice message", %{paths: paths} do
      Logger.notice("Logging a notice message!")
      Log.notice(:message, {:notice, :info, __ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [notice]\s
             Actual 'notice' message no longer reported as 'info'...
             """
    end
  end

  describe "Log.warning/2" do
    test "logs a warning message", %{paths: paths} do
      Logger.warning("Logging a warning message!")
      Log.warning(:message, {:warning, :warn, __ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.warning) =~ """
             [warning]\s
             Actual 'warning' message no longer reported as 'warn'...
             """
    end
  end

  describe "Log.critical/2" do
    test "logs a critical message", %{paths: paths} do
      Logger.critical("Logging a critical message!")
      Log.critical(:message, {:critical, :error, __ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.error) =~ """
             [critical]\s
             Actual 'critical' message no longer reported as 'error'...
             """
    end
  end

  describe "Log.alert/2" do
    test "logs an alert message", %{paths: paths} do
      Logger.alert("Logging an alert message!")
      Log.alert(:message, {:alert, :error, __ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.error) =~ """
             [alert]\s
             Actual 'alert' message no longer reported as 'error'...
             """
    end
  end

  describe "Log.emergency/2" do
    test "logs an emergency message", %{paths: paths} do
      Logger.emergency("Logging an emergency message!")
      Log.emergency(:message, {:emergency, :error, __ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.error) =~ """
             [emergency]\s
             Actual 'emergency' message no longer reported as 'error'...
             """
    end
  end

  describe "Log.info/2" do
    test "logs an i-n-f-o m-e-s-s-a-g-e", %{games: games, paths: paths} do
      Log.info(:joined_game, {games.stephan.player, games.stephan, __ENV__})
      Process.sleep(@test_wait)

      heredoc = """
      [info]\s
      Note that Stephan...
      • Has joined game: STEPHAN
      • Game state: :starting
      • App: file_only_logger
      • Library: file_only_logger
      • Module: File.Only.LoggerTest.Log
      • Function:\s
        File.Only.LoggerTest.'test Log.info/2 logs an i-n-f-o m-e-s-s-a-g-e'/1
      """

      assert File.read!(paths.info) =~ heredoc
    end

    test "logs similar info msg", %{games: games, paths: paths} do
      Log.info(:joined_game, {games.anthony.player, games.anthony, __ENV__})
      Process.sleep(@test_wait)

      heredoc = """
      [info]\s
      Note that Anthony...
      • Has joined game: ANTHONY
      • Game state: :on_going
      • App: file_only_logger
      • Library: file_only_logger
      • Module: File.Only.LoggerTest.Log
      • Function: File.Only.LoggerTest.'test Log.info/2 logs similar info msg'/1
      """

      assert File.read!(paths.info) =~ heredoc
    end

    test "logs other info message", %{games: games, paths: paths} do
      Log.info(:joined_game_also, {games.raymond.player, games.raymond})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s
             Note that Raymond...
             • Has joined game: RAYMOND
             • Game state: :stopping
             • App: file_only_logger
             • Library: file_only_logger
             • Module: File.Only.LoggerTest.Log
             """
    end

    test "logs extra info message", %{paths: paths} do
      use File.Only.Logger

      app = lib()
      all_env = get_all_env(app)
      Log.info(:all_env, {app, all_env})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s
             Application environment:
             • For app: file_only_logger
             • Key-value pairs:
             """
    end

    test "logs info message for line break with binary arg", %{paths: paths} do
      Log.info(:binary_break, {__ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s
             Checking line break with binary arg:
             • Relative path: test/file/only/logger_test.exs
             • Absolute path:\s
             """
    end
  end

  describe "config/runtime.exs overrides config/config.exs" do
    test "runtime.exs if present overrides config.exs" do
      if File.exists?("config/runtime.exs") do
        Logger.notice("'config/runtime.exs' exists...")
        Logger.notice("env is #{@env}")
        assert @env == "test ➔ from config/runtime.exs"
      else
        Logger.notice("'config/runtime.exs' does not exist...")
        Logger.notice("env is #{@env}")
        assert @env == "test ➔ from config/config.exs"
      end
    end
  end
end
