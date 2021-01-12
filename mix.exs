defmodule File.Only.Logger.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_only_logger,
      version: "0.1.26",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "File-Only Logger",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps(),
      # File.Only.Logger.lib/0...
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/file_only_logger"
  end

  defp description do
    """
    A simple logger which writes messages to files only (not to the console).
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:logger_file_backend, "~> 0.0.9"},
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end
end
