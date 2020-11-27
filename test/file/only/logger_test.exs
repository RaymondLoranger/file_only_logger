defmodule File.Only.LoggerTest.Log do
  use File.Only.Logger

  warn :low_points, {player} do
    """
    \nCareful #{player.name}...
    • Points left: #{player.points}
    """
  end

  info :joined_game, {player, game} do
    """
    \nNote that #{player.name}...
    • Has joined game: #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
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

    paths = %{
      warn: Application.get_env(:logger, :warn_log)[:path],
      info: Application.get_env(:logger, :info_log)[:path]
    }

    %{games: games, paths: paths}
  end

  describe "Log.warn/2" do
    test "logs a warning message", %{games: games, paths: paths} do
      Log.warn(:low_points, {games.anthony.player})
      Process.sleep(99)

      assert File.read!(paths.warn) =~ """
             [warn]\s\s
             Careful Anthony...
             • Points left: 43
             """
    end
  end

  describe "Log.info/2" do
    test "logs an info message", %{games: games, paths: paths} do
      Log.info(:joined_game, {games.stephan.player, games.stephan})
      Process.sleep(99)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Note that Stephan...
             • Has joined game: STEPHAN
             • Game state: :starting
             """
    end

    test "logs other info message", %{games: games, paths: paths} do
      Log.info(:joined_game_plus, {games.raymond.player, games.raymond})
      Process.sleep(99)

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
      Process.sleep(99)

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
      Process.sleep(99)

      assert File.read!(paths.info) =~ """
             [info]\s\s
             Application environment:
             • For app: file_only_logger
             • Key-value pairs:
             """
    end
  end
end
