# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :simon, SimonWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Wbob6zzY74ecQ91FRKPODbR0G6wIs3uMq3WVdiVpdEhmMfmzAA97Y78fW1xaQZIe",
  render_errors: [view: SimonWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Simon.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "6AjPHGC05IWLda7yJ0USXnkO6fMZXPyJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  lslim: PhoenixSlime.LiveViewEngine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
