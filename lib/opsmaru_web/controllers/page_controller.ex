defmodule OpsmaruWeb.PageController do
  use OpsmaruWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
