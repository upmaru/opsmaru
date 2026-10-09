defmodule Opsmaru.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    case Application.get_env(:opsmaru, :deployment_mode, :embedded) do
      :embedded ->
        Supervisor.start_link([OpsmaruWeb.Telemetry],
          strategy: :one_for_one,
          name: Opsmaru.Supervisor
        )

      :standalone ->
        children = [
          OpsmaruWeb.Telemetry,
          Opsmaru.Repo,
          {Phoenix.PubSub, name: Opsmaru.PubSub},
          OpsmaruWeb.Endpoint
        ]

        Supervisor.start_link(children, strategy: :one_for_one, name: Opsmaru.Supervisor)

      mode ->
        {:error, {:invalid_deployment_mode, mode}}
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    if Process.whereis(OpsmaruWeb.Endpoint) do
      OpsmaruWeb.Endpoint.config_change(changed, removed)
    else
      :ok
    end
  end
end
