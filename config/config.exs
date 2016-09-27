# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :sas,
  ecto_repos: [Sas.Repo]

# Configures the endpoint
config :sas, Sas.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "//EM11g8+FcO8npJq0TYsDqucVaPgwPbgRpRuLMhZrPl95vhEqEn67tmgPljLU70",
  render_errors: [view: Sas.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Sas.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :money, default_currency: :THB

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
