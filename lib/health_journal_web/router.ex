defmodule HealthJournalWeb.Router do
  use HealthJournalWeb, :router
  use Plug.ErrorHandler # for Rollbax
  import Phoenix.LiveView.Router
  import HealthJournalWeb.AuthPlugs, only: [load_current_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    # plug :fetch_flash # Apparently fetch_live_flash makes this obsolete?
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # In dev, preview all "sent" emails at localhost:4000/sent_emails
  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", HealthJournalWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/auth/signup", AuthController, :signup
    post "/auth/signup", AuthController, :signup_submit
    get "/auth/login", AuthController, :login
    post "/auth/login", AuthController, :login_submit
    get "/auth/logout", AuthController, :logout
    get "/auth/request_email_confirm", AuthController, :request_email_confirm
    post "/auth/request_email_confirm", AuthController, :request_email_confirm_submit
    get "/auth/confirm_email", AuthController, :confirm_email
    get "/auth/request_password_reset", AuthController, :request_password_reset
    post "/auth/request_password_reset", AuthController, :request_password_reset_submit
    get "/auth/reset_password", AuthController, :reset_password
    post "/auth/reset_password", AuthController, :reset_password_submit

    get "/account/edit", UserController, :edit
    patch "/account/update", UserController, :update
    patch "/account/update_email", UserController, :update_email

    resources "/journal", JournalController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", HealthJournalWeb do
  #   pipe_through :api
  # end

  defp handle_errors(conn, data), do: HealthJournalWeb.ErrorPlugs.handle_errors(conn, data)
end
