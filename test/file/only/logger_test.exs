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
    • Inside function:
      #{fun(env)}
    #{from()}
    """
  end

  info :joined_game_plus, {player, game} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    • App: #{app()}
    • Library: #{lib()}
    • Module: #{mod()}
    """
  end

  info :joined_game_from, {player, game} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    #{from()}
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
end

defmodule File.Only.LoggerTest do
  use ExUnit.Case, async: true

  alias File.Only.Logger
  alias File.Only.LoggerTest.Log

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

    # Clear each log file...
    paths
    |> Map.values()
    |> Enum.reject(&is_nil/1)
    |> Enum.each(&File.write(&1, ""))

    %{games: games, paths: paths}
  end

  describe "Log.notice/2" do
    test "logs a notice message", %{paths: paths} do
      Log.notice(:message, {:notice, :info})
      Process.sleep(222)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Actual 'notice' message reported as 'info'...
             """
    end
  end

  describe "Log.warning/2" do
    test "logs a warning message", %{paths: paths} do
      Log.warning(:message, {:warning, :warn})
      Process.sleep(222)

      assert File.read!(paths.warn) =~ """
             [warn]\s\s
             Actual 'warning' message reported as 'warn'...
             """
    end
  end

  describe "Log.critical/2" do
    test "logs a critical message", %{paths: paths} do
      Log.critical(:message, {:critical, :error})
      Process.sleep(222)

      assert File.read!(paths.error) =~ """
             [error]\s
             Actual 'critical' message reported as 'error'...
             """
    end
  end

  describe "Log.alert/2" do
    test "logs a alert message", %{paths: paths} do
      Log.alert(:message, {:alert, :error})
      Process.sleep(222)

      assert File.read!(paths.error) =~ """
             [error]\s
             Actual 'alert' message reported as 'error'...
             """
    end
  end

  describe "Log.emergency/2" do
    test "logs a emergency message", %{paths: paths} do
      Log.emergency(:message, {:emergency, :error})
      Process.sleep(222)

      assert File.read!(paths.error) =~ """
             [error]\s
             Actual 'emergency' message reported as 'error'...
             """
    end
  end

  describe "Log.warn/2" do
    test "logs a warning message", %{games: games, paths: paths} do
      Log.warn(:low_points, {games.anthony.player})
      Process.sleep(222)

      assert File.read!(paths.warn) =~ """
             [warn]\s\s
             Careful Anthony...
             • Points left: 43
             """
    end
  end

  describe "Log.info/2" do
    test "logs an info message", %{games: games, paths: paths} do
      Log.info(:joined_game, {games.stephan.player, games.stephan, __ENV__})
      Process.sleep(222)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Note that Stephan...
             • Has joined game: STEPHAN
             • Game state: :starting
             • Inside function:
               File.Only.LoggerTest.'test Log.info/2 logs an info message'/1
             • App: undefined
             • Library: file_only_logger
             • Module: File.Only.LoggerTest.Log
             """
    end

    test "logs other info message", %{games: games, paths: paths} do
      Log.info(:joined_game_plus, {games.raymond.player, games.raymond})
      Process.sleep(222)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Note that Raymond...
             • Has joined game: RAYMOND
             • Game state: :stopping
             • App: undefined
             • Library: file_only_logger
             • Module: File.Only.LoggerTest.Log
             """
    end

    test "logs similar info message", %{games: games, paths: paths} do
      Log.info(:joined_game_from, {games.anthony.player, games.anthony})
      Process.sleep(222)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Note that Anthony...
             • Has joined game: ANTHONY
             • Game state: :on_going
             • App: undefined
             • Library: file_only_logger
             • Module: File.Only.LoggerTest.Log
             """
    end

    test "logs extra info message", %{paths: paths} do
      use File.Only.Logger

      app = lib()
      all_env = Application.get_all_env(app)
      Log.info(:all_env, {app, all_env})
      Process.sleep(222)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Application environment:
             • For app: file_only_logger
             • Key-value pairs:
             """
    end
  end
end
