use Mix.Config

config :ordered_siblings, ecto_repos: [OrderedSiblings.Repo]

config :ordered_siblings, OrderedSiblings.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ordered_siblings_test",
  hostname: "localhost",
  poolsize: 10,
  pool: Ecto.Adapters.SQL.Sandbox
