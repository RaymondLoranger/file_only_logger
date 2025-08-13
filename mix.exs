defmodule File.Only.Logger.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_only_logger,
      version: "0.2.41",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "File-Only Logger",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/file_only_logger"
  end

  defp description do
    """
    A simple logger that writes messages to log files only (not to the console).
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "config/persist*.exs"],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :runtime_tools, :wx],
      mod: {File.Only.Logger.App, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end
end
