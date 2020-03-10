defmodule HealthJournalWeb.JournalController do
  use HealthJournalWeb, :controller
  alias HealthJournal.Data
  alias HealthJournal.Data.User

  plug :must_be_logged_in

  def index(conn, _params) do
    raise "TODO"
  end
end
