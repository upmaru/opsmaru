defmodule Opsmaru.Repo do
  use Ecto.Repo,
    otp_app: :opsmaru,
    adapter: Ecto.Adapters.Postgres
end
