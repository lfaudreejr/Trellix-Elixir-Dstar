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
    plug :accepts, ["json", "sse"]
  end

  scope "/", TrellixWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/sse", PageController, :sse
    get "/board/:id", BoardController, :board
    get "/board/:id/name/edit", BoardController, :edit_board_name_get
    get "/board/:id/name/edit/cancel", BoardController, :edit_board_name_cancel
    get "/board/:id/column/create", BoardController, :board_column_create_get
    get "/board/:id/column/create/cancel", BoardController, :board_column_create_cancel
    get "/column/:id/card/create", BoardController, :column_card_create_get
    get "/column/:id/card/create/cancel", BoardController, :column_card_create_cancel
    get "/column/:id/name/edit", BoardController, :edit_column_name_get
    get "/column/:id/name/edit/cancel", BoardController, :edit_column_name_cancel

    put "/board/:id/name/edit/submit", BoardController, :edit_board_name_submit
    put "/card/:id/reorder", BoardController, :card_reorder
    put "/column/:id/name/edit/submit", BoardController, :edit_column_name_submit

    post "/board", BoardController, :board_create
    post "/board/:id/column/create", BoardController, :board_column_create_submit
    post "/column/:id/card/create", BoardController, :column_card_create_submit
    post "/card/:id/reorder", BoardController, :card_reorder

    delete "/board/:id", BoardController, :board_delete
    delete "/card/:id", BoardController, :column_card_delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", TrellixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:trellix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TrellixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

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
end
