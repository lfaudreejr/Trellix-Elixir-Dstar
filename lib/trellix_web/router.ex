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
    get "/board/:id", BoardController, :get
    get "/column/:column_id/card/create", ColumnController, :get_create_column_card_form
    get "/column/:column_id/card/create/cancel", ColumnController, :get_column_card_create_button

    post "/board", BoardController, :create
    post "/board/:board_id/column", BoardController, :create_column
    post "/column/:column_id/card/create", ColumnController, :post_create_column_card_form

    put "/card/:id/reorder", ColumnController, :column_card_reorder
    put "/board/:board_id/name", BoardController, :change_name
    put "/column/:column_id/name", ColumnController, :change_name

    delete "/board/:id", BoardController, :delete
    delete "/column/:column_id/card/:id", ColumnController, :delete_column_card
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
