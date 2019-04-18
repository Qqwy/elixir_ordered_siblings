defmodule OrderedSiblings.Mixfile do
  use Mix.Project

  def project do
    [app: :ordered_siblings,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env),
     aliases: aliases(),

     name: "OrderedSiblings",
     description: description(),
     package: package(),
     source_url: "https://github.com/Qqwy/elixir_ordered_siblings"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 3.1"},
      {:postgrex, "~> 0.13"},
      {:poison, "~> 3.1"},

      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "test": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp package do
    [
      name: :ordered_siblings,
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Wiebe-Marten Wijnja/Qqwy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Qqwy/elixir_ordered_siblings" }
    ]
  end

  defp description do
    """
    Ordered siblings in Ecto: Order and reorder comments in threads, songs in playlists, images in albums, etc.
    """
  end
end
