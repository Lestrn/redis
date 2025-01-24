# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :redis,
  ecto_repos: [Redis.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :redis, RedisWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: RedisWeb.ErrorHTML, json: RedisWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Redis.PubSub,
  live_view: [signing_salt: "LkFkUmpt"]

config :redis, :redis,
  url: System.get_env("REDIS_URL") || "redis://localhost:6379"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :redis, Redis.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
import_config "../deps/moon/config/surface.exs"

config :surface, :components, [
  # put here your app configs for surface
]

config :esbuild,
  version: "0.17.11",
  redis: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env:  %{"NODE_PATH" => "/root/project/lib/moon_web/components/deps:./node_modules"}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  redis: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
