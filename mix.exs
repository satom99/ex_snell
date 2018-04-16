defmodule Snell.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_snell,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      description: "JSON Predicate implementation.",
      source_url: "https://github.com/satom99/ex_snell"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Santiago Tortosa"],
      links: %{
        "GitHub" => "https://github.com/satom99/ex_snell",
        "Mineteria" => "https://mineteria.com"
      }
    ]
  end
end
