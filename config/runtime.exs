import Config

# Loading Opsmaru as a dependency never infers standalone mode from PHX_SERVER.
mode =
  case System.get_env("OPSMARU_MODE") do
    nil -> Application.get_env(:opsmaru, :deployment_mode, :embedded)
    "embedded" -> :embedded
    "standalone" -> :standalone
    _ -> raise "OPSMARU_MODE must be embedded or standalone"
  end

config :opsmaru, :deployment_mode, mode

if mode == :standalone and System.get_env("PHX_SERVER") do
  config :opsmaru, OpsmaruWeb.Endpoint, server: true
end

if config_env() == :dev and mode == :standalone do
  config :opsmaru, OpsmaruWeb.Endpoint,
    http: [
      ip: {127, 0, 0, 1},
      port: String.to_integer(System.get_env("PORT", "4000")),
      protocol_options: [invalid_response_headers: :error_terminate]
    ],
    live_reload: [
      web_console_logger: true,
      patterns: [
        ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
        ~r"lib/opsmaru_web/router\.ex$"E,
        ~r"lib/opsmaru_web/(controllers|live|components)/.*\.(ex|heex)$"E
      ]
    ]
end

if config_env() == :prod and mode == :standalone do
  required = fn name ->
    System.get_env(name) || raise "standalone mode requires #{name}"
  end

  database_url = required.("DATABASE_URL")
  secret_key_base = required.("SECRET_KEY_BASE")
  host = required.("PHX_HOST")
  certfile = required.("OPSMARU_TLS_CERTFILE")
  keyfile = required.("OPSMARU_TLS_KEYFILE")

  ip =
    case :inet.parse_address(String.to_charlist(System.get_env("OPSMARU_BIND_IP", "127.0.0.1"))) do
      {:ok, value} -> value
      {:error, _} -> raise "OPSMARU_BIND_IP must be an IP address"
    end

  port = String.to_integer(System.get_env("PORT", "8443"))
  if port < 1 or port > 65_535, do: raise("PORT must be between 1 and 65535")

  config :opsmaru, Opsmaru.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

  config :opsmaru, OpsmaruWeb.Endpoint,
    url: [host: host, port: port, scheme: "https"],
    http: false,
    https: [
      ip: ip,
      port: port,
      certfile: certfile,
      keyfile: keyfile,
      protocol_options: [invalid_response_headers: :error_terminate]
    ],
    secret_key_base: secret_key_base
end
