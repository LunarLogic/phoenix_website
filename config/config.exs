# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_website,
  ecto_repos: [PhoenixWebsite.Repo]

# Configures the endpoint
config :phoenix_website, PhoenixWebsiteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DOWHlVL1H3lWribIiOSCBmA7w5dm3LxM9sooLP80Adj8qVqURwArkEWkfqJ4tIcw",
  render_errors: [view: PhoenixWebsiteWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixWebsite.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
