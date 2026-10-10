# Run separately from the web test suite so no standalone application has started.
Application.load(:opsmaru)
for dependency <- Application.spec(:opsmaru, :applications) do
  {:ok, _} = Application.ensure_all_started(dependency)
end

Application.put_env(:opsmaru, :deployment_mode, :embedded)
System.put_env("PHX_SERVER", "true")
System.put_env("PORT", "not-a-port")
Application.put_env(:opsmaru, OpsmaruWeb.Endpoint, server: true)

# Read the actual release runtime config: hostile PORT must not even be parsed.
Config.Reader.read!("config/runtime.exs", env: :prod, target: :host)

ports = MapSet.new(Port.list())
root = Path.join(System.tmp_dir!(), "opsmaru-passive-#{System.unique_integer([:positive])}")
context = Opsmaru.Context.new!(owner: :fixture, identity: :verified, ready?: fn -> false end, private_state: root)
connection = Opsmaru.Incus.Connection.unix!(Path.join(root, "incus.sock"), owner: :fixture)
{:error, :host_not_ready} = Opsmaru.Context.authorize(context, connection)

{:ok, _} = Application.ensure_all_started(:opsmaru)

for name <- [OpsmaruWeb.Endpoint, Opsmaru.Repo, Opsmaru.PubSub] do
  if Process.whereis(name), do: raise("embedded startup unexpectedly started #{inspect(name)}")
end

[] = Supervisor.which_children(Opsmaru.Supervisor)
false = File.exists?(root)
true = MapSet.subset?(MapSet.new(Port.list()), ports)

# Dependency restarts create no workers, state or backend connection.
Application.stop(:opsmaru)
{:ok, _} = Application.ensure_all_started(:opsmaru)
[] = Supervisor.which_children(Opsmaru.Supervisor)
false = File.exists?(root)
true = MapSet.subset?(MapSet.new(Port.list()), ports)

Application.stop(:opsmaru)
IO.puts("Embedded startup/restart passed: empty supervision, no new ports, state, Endpoint or Repo")
