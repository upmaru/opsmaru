# Run separately from the web test suite so no standalone application has started.
Application.put_env(:opsmaru, :deployment_mode, :embedded)
System.put_env("PHX_SERVER", "true")
System.put_env("PORT", "45678")

{:ok, _} = Application.ensure_all_started(:opsmaru)

for name <- [OpsmaruWeb.Endpoint, Opsmaru.Repo, Opsmaru.PubSub] do
  if Process.whereis(name), do: raise("embedded startup unexpectedly started #{inspect(name)}")
end

Application.stop(:opsmaru)
IO.puts("Embedded startup passed: no endpoint, repository or standalone PubSub")
