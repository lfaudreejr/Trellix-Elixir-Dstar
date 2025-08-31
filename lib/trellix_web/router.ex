defmodule TrellixWeb.Router do
  use TrellixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :assign_client_id
    plug :fetch_live_flash
    plug :put_root_layout, html: {TrellixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :sse do
    plug :accepts, ["sse"]
  end

  scope "/", TrellixWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/sse", TrellixWeb do
    pipe_through [:browser, :sse]

    get "/", SSEController, :sse_req
  end

  # Other scopes may use custom stacks.
  # scope "/api", TrellixWeb do
  #   pipe_through :api
  # end

  defp assign_client_id(conn, _opts) do
    case get_session(conn, :client_id) do
      nil ->
        id = Ecto.UUID.generate()

        conn
        |> put_session(:client_id, id)
        |> assign(:client_id, id)

      id ->
        assign(conn, :client_id, id)
    end
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:trellix, :dev_routes) do

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
