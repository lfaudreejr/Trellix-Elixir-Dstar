defmodule TrellixWeb.PageController do
  use TrellixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
