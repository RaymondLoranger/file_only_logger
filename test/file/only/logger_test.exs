defmodule File.Only.LoggerTest.Log do
  use File.Only.Logger

  notice :message, {logged_as, reported_as} do
    """
    \nActual '#{logged_as}' message reported as '#{reported_as}'...
    • Logged as: '#{logged_as}'
    • Reported as: '#{reported_as}'
    """
  end

  warning :message, {logged_as, reported_as} do
    """
    \nActual '#{logged_as}' message reported as '#{reported_as}'...
    • Logged as: '#{logged_as}'
    • Reported as: '#{reported_as}'
    """
  end

  critical :message, {logged_as, reported_as} do
    """
    \nActual '#{logged_as}' message reported as '#{reported_as}'...
    • Logged as: '#{logged_as}'
    • Reported as: '#{reported_as}'
    """
  end

  alert :message, {logged_as, reported_as} do
    """
    \nActual '#{logged_as}' message reported as '#{reported_as}'...
    • Logged as: '#{logged_as}'
    • Reported as: '#{reported_as}'
    """
  end

  emergency :message, {logged_as, reported_as} do
    """
    \nActual '#{logged_as}' message reported as '#{reported_as}'...
    • Logged as: '#{logged_as}'
    • Reported as: '#{reported_as}'
    """
  end

  warn :low_points, {player} do
    """
    \nCareful #{player.name}...
    • Points left: #{player.points}
    """
  end

  info :joined_game, {player, game, env} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    #{from(env, __MODULE__)}
    """
  end

  info :joined_game_also, {player, game} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    • App: #{app()}
    • Library: #{lib()}
    • Module: #{mod()}
    """
  end

  info :joined_game_too, {player, game, env} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    #{from(env, __MODULE__)}
    """
  end

  info :all_env, {app, all_env} do
    """
    \nApplication environment:
    • For app: #{app}
    • Key-value pairs:
      #{inspect(all_env)}
    """
  end

  info :binary_break, {env} do
    """
    \nChecking line break with binary arg:
    • Relative path: #{Path.relative_to_cwd(env.file) |> maybe_break(17)}
    • Absolute path: #{Path.expand(env.file) |> maybe_break(17)}
    """
  end
end

defmodule File.Only.LoggerTest do
  use ExUnit.Case, async: true
  use PersistConfig

  alias File.Only.Logger
  alias File.Only.LoggerTest.Log

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
    paths = %{
      debug: Application.get_env(:logger, :debug_log)[:path],
      info: Application.get_env(:logger, :info_log)[:path],
      warn: Application.get_env(:logger, :warn_log)[:path],
      error: Application.get_env(:logger, :error_log)[:path]
    }

    # Delete each log file...
    # paths
    # |> Map.values()
    # |> Enum.reject(&is_nil/1)
    # |> Enum.each(&File.rm/1)

    %{games: games, paths: paths}
  end

  describe "Log.notice/2" do
    test "logs a notice message", %{paths: paths} do
      Log.notice(:message, {:notice, :info})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Actual 'notice' message reported as 'info'...
             """
    end
  end

  describe "Log.warning/2" do
    test "logs a warning message", %{paths: paths} do
      Log.warning(:message, {:warning, :warn})
      Process.sleep(@test_wait)

      assert File.read!(paths.warn) =~ """
             [warn]\s\s
             Actual 'warning' message reported as 'warn'...
             """
    end
  end

  describe "Log.critical/2" do
    test "logs a critical message", %{paths: paths} do
      Log.critical(:message, {:critical, :error})
      Process.sleep(@test_wait)

      assert File.read!(paths.error) =~ """
             [error]\s
             Actual 'critical' message reported as 'error'...
             """
    end
  end

  describe "Log.alert/2" do
    test "logs an alert message", %{paths: paths} do
      Log.alert(:message, {:alert, :error})
      Process.sleep(@test_wait)

      assert File.read!(paths.error) =~ """
             [error]\s
             Actual 'alert' message reported as 'error'...
             """
    end
  end

  describe "Log.emergency/2" do
    test "logs an emergency message", %{paths: paths} do
      Log.emergency(:message, {:emergency, :error})
      Process.sleep(@test_wait)

      assert File.read!(paths.error) =~ """
             [error]\s
             Actual 'emergency' message reported as 'error'...
             """
    end
  end

  describe "Log.warn/2" do
    test "logs a warning message", %{games: games, paths: paths} do
      Log.warn(:low_points, {games.anthony.player})
      Process.sleep(@test_wait)

      assert File.read!(paths.warn) =~ """
             [warn]\s\s
             Careful Anthony...
             • Points left: 43
             """
    end
  end

  describe "Log.info/2" do
    test "logs an i-n-f-o m-e-s-s-a-g-e", %{games: games, paths: paths} do
      Log.info(:joined_game, {games.stephan.player, games.stephan, __ENV__})
      Process.sleep(@test_wait)

      heredoc = """
      [info]\s\s
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

    test "logs other info message", %{games: games, paths: paths} do
      Log.info(:joined_game_also, {games.raymond.player, games.raymond})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Note that Raymond...
             • Has joined game: RAYMOND
             • Game state: :stopping
             • App: file_only_logger
             • Library: file_only_logger
             • Module: File.Only.LoggerTest.Log
             """
    end

    test "logs similar info msg", %{games: games, paths: paths} do
      Log.info(:joined_game_too, {games.anthony.player, games.anthony, __ENV__})
      Process.sleep(@test_wait)

      heredoc = """
      [info]\s\s
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

    test "logs extra info message", %{paths: paths} do
      use File.Only.Logger

      app = lib()
      all_env = Application.get_all_env(app)
      Log.info(:all_env, {app, all_env})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Application environment:
             • For app: file_only_logger
             • Key-value pairs:
             """
    end

    test "logs info message for line break with binary arg", %{paths: paths} do
      Log.info(:binary_break, {__ENV__})
      Process.sleep(@test_wait)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Checking line break with binary arg:
             • Relative path: test/file/only/logger_test.exs
             • Absolute path:\s
             """
    end
  end
end
