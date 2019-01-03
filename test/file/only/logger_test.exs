defmodule Log do
  use File.Only.Logger

  warn :low_points, {player} do
    """
    \nCareful #{player.name}:
    • Points left: #{player.points}
    """
  end

  info :joined_game, {player, game} do
    """
    \nNote that #{player.name}:
    • Has joined game #{inspect(game.name)}
    • Game state: #{inspect(game.state)}
    """
  end
end

defmodule File.Only.LoggerTest do
  use ExUnit.Case, async: true

  alias File.Only.Logger

  doctest Logger

  setup_all do
    Application.put_env(:file_only_logger, :log?, true)
    anthony = %{name: "Anthony", points: 43}
    skyfall = %{name: "skyfall", state: :ongoing}
    games = %{skyfall: skyfall}
    players = %{anthony: anthony}
    {:ok, games: games, players: players}
  end

  describe "Log.warn/2" do
    test "logs a warning message", %{players: players} do
      warn_path = Application.get_env(:logger, :warn_log)[:path]
      Log.Reset.clear_log(warn_path)
      Log.warn(:low_points, {players.anthony})
      Process.sleep(100)

      assert File.read!(warn_path) =~ """
             [warn]\s\s
             Careful Anthony:
             • Points left: 43
             """
    end
  end

  describe "Log.info/2" do
    test "logs an info message", %{players: players, games: games} do
      info_path = Application.get_env(:logger, :info_log)[:path]
      Log.Reset.clear_log(info_path)
      Log.info(:joined_game, {players.anthony, games.skyfall})
      Process.sleep(100)

      assert File.read!(info_path) =~ """
             [info]\s\s
             Note that Anthony:
             • Has joined game "skyfall"
             • Game state: :ongoing
             """
    end
  end
end
