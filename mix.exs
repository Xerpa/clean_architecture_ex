defmodule CleanArchitecture.MixProject do
  use Mix.Project

  def project do
    [
      app: :clean_architecture,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp description do
    "Library that contains modules used to develop an Elixir Application using Clean Architecture."
  end

  defp package() do
    [
      name: "clean_architecture",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Xerpa/clean_architecture_ex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.4"},

      # Test
      {:excoveralls, "~> 0.14", only: :test, runtime: false},
      {:junit_formatter, "~> 3.3", only: :test, runtime: false},
      {:mock, "~> 0.3", only: :test},

      # Lint
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:credo_naming, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
