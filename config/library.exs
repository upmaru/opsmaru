import Config

# No standalone test config, database credentials, endpoint or Ecto test alias.
config :opsmaru, :deployment_mode, :embedded
config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
