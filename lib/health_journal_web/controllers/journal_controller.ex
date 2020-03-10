defmodule HealthJournalWeb.JournalController do
  use HealthJournalWeb, :controller

  plug :must_be_logged_in

  def index(conn, _params) do
    user = conn.assigns.current_user
    live_render(conn, HealthJournalWeb.JournalIndexLive, session: %{"user_id" => user.id})
  end
end
