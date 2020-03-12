defmodule HealthJournalWeb.JournalIndexLive do
  use Phoenix.LiveView
  alias HealthJournal.Repo
  alias HealthJournal.Data
  alias HealthJournal.Data.Day

  def render(assigns) do
    HealthJournalWeb.JournalView.render("index.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    user = Repo.get!(Data.User, user_id)
    ensure_entry(user, Date.utc_today())
    socket = assign(socket, user: user, editing: %{date: nil, field: nil})
    socket = assign(socket, days: load_days(socket))
    {:ok, socket}
  end

  def handle_event("add-day", %{"day" => %{"date" => date_str}}, socket) do
    date = Date.from_iso8601!(date_str)
    ensure_entry(socket.assigns.user, date)
    days = load_days(socket)
    socket = assign(socket, days: days)
    {:noreply, socket}
  end

  def handle_event("set-editing", %{"date" => date, "field" => field}, socket) do
    socket = assign(socket, editing: %{date: date, field: field})
    {:noreply, socket}
  end

  def handle_event("update-day", %{"day" => day_params}, socket) do
    day_id = Map.fetch!(day_params, "id")
    day = Day.filter(user: socket.assigns.user, id: day_id) |> Repo.one!()
    Data.update_day!(day, day_params, :owner)
    socket = assign(socket, days: load_days(socket))
    {:noreply, socket}
  end

  #
  # Helpers
  #

  defp load_days(socket) do
    Day.filter(user: socket.assigns.user, order: :date_desc) |> Repo.all()
  end

  defp ensure_entry(user, date) do
    if Repo.count(Day.filter(user: user, date: date)) == 0 do
      Data.insert_day!(%Day{user_id: user.id, date: date}, %{}, :owner)
    end
  end
end
