defmodule KomipuraBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :komipura_bot,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison, :extwitter, :timex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:floki, "~> 0.18"},
      {:oauther, "~> 1.1"},
      {:extwitter, "~> 0.8"},
      {:timex, "~> 3.1"}
    ]
  end
end
