defmodule SymmetricEncryption.MixProject do
  use Mix.Project

  def project do
    [
      app: :symmetric_encryption,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SymmetricEncryption.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: [:dev, :test]},
      {:ecto, "~> 3.5", only: [:dev, :test]}
    ]
  end
end
