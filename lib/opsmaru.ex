defmodule Opsmaru do
  @moduledoc """
  Opsmaru central service application.

  Starting `:opsmaru` in its default `:embedded` deployment mode starts an
  empty supervisor. It never reads credentials, creates state, starts web/SQL
  services or opens a backend. Standalone mode remains an explicitly selected
  Phoenix scaffold.

  The portable Incus client lives in the separate `:opsmaru_incus` library
  (https://github.com/upmaru/opsmaru-incus).
  """
end
