ExUnit.start()

if Mix.env() == :test do
  Ecto.Adapters.SQL.Sandbox.mode(Opsmaru.Repo, :manual)
end
