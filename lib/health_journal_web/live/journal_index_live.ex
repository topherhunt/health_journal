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
    socket = assign(socket, user: user, changesets: %{})
    socket = assign(socket, days: load_days(socket))
    {:ok, socket}
  end

  def handle_event("add-date", %{"day" => %{"date" => date_str}}, socket) do
    date = Date.from_iso8601!(date_str)
    ensure_entry(socket.assigns.user, date)
    days = load_days(socket)
    socket = assign(socket, days: days)
    {:noreply, socket}
  end

  def handle_event("edit-date", %{"date" => date_str}, socket) do
    date = Date.from_iso8601!(date_str)
    day = socket.assigns.days |> Enum.find(& &1.date == date)
    changeset = Day.changeset(day, %{}, :owner)
    changesets = socket.assigns.changesets |> Map.put(date, changeset)
    socket = assign(socket, changesets: changesets)
    {:noreply, socket}
  end

  def handle_event("close-edit-date", %{"date" => date_str}, socket) do
    date = Date.from_iso8601!(date_str)
    changesets = socket.assigns.changesets |> Map.delete(date)
    socket = assign(socket, changesets: changesets)
    {:noreply, socket}
  end

  def handle_event("update-date", %{"day" => day_params}, socket) do
    day_id = Map.fetch!(day_params, "id")
    day = Day.filter(user: socket.assigns.user, id: day_id) |> Repo.one!()
    day = Data.update_day!(day, day_params, :owner)
    changeset = Day.changeset(day, %{}, :owner)
    changesets = socket.assigns.changesets |> Map.put(day.date, changeset)
    socket = assign(socket, days: load_days(socket), changesets: changesets)
    # I don't think we need to update the changeset.
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
