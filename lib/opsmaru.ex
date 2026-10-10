defmodule Opsmaru do
  @moduledoc """
  Passive embedded OTP dependency and portable Incus library.

  Starting `:opsmaru` in its default `:embedded` deployment mode starts an
  empty supervisor. It never reads credentials, creates state, starts web/SQL
  services or opens a backend. A host owns identity, authorization, private
  state, endpoint and runtime lifecycle. Public calls receive an explicit
  `Opsmaru.Context` and `Opsmaru.Incus.Connection`; no global remote exists.

  Hosts may explicitly supervise `Opsmaru.ClientSupervisor` to bound concurrent
  calls. That supervisor starts no work and never recovers/replays mutations.
  Standalone mode remains an explicitly selected Phoenix scaffold.
  """
end
