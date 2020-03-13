defmodule HealthJournalWeb.JournalIndexLive do
  use Phoenix.LiveView
  alias HealthJournal.Helpers, as: H
  alias HealthJournal.Repo
  alias HealthJournal.Data
  alias HealthJournal.Data.Day
  require Logger

  @one_hour 1000 * 60 * 60

  def render(assigns) do
    HealthJournalWeb.JournalView.render("index.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    if connected?(socket), do: :timer.send_interval(@one_hour, self(), :notify)

    user = Repo.get!(Data.User, user_id)
    ensure_entry(user, Date.utc_today())
    socket = assign(socket, user: user, editing: %{date: nil, field: nil}, notifications: [])
    socket = assign(socket, days: load_days(socket))
    {:ok, socket}
  end

  def handle_info(:notify, socket) do
    if hours_since_last_update(socket) >= 6 do
      Logger.info "#{__MODULE__}: Sending reminder notification."
      {:noreply, add_notification(socket, random_reminder_text())}
    else
      Logger.info "#{__MODULE__}: No reminder notification needed."
      {:noreply, socket}
    end
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

  defp hours_since_last_update(socket) do
    last_update =
      socket.assigns.days
      # Ignore empty entries
      |> Enum.filter(& H.present?("#{&1.sleep} #{&1.energy} #{&1.comfort} #{&1.food} #{&1.vitamins} #{&1.exercise} #{&1.reflections}"))
      |> Enum.map(& &1.updated_at)
      |> Enum.sort(& NaiveDateTime.compare(&1, &2) != :gt)
      |> List.last() || DateTime.utc_now()

    Timex.diff(DateTime.utc_now(), last_update, :hours)
  end

  defp add_notification(socket, text) do
    socket |> assign(notifications: socket.assigns.notifications ++ [text])
  end

  defp random_reminder_text() do
    time_of_day = DateTime.utc_now().hour

    greetings =
      ["Greetings!", "Howdy!", "Hi!", "Hi there!", "", "How's it going?"] ++
      (if time_of_day <= 7, do: ["You're up early!"], else: []) ++
      (if time_of_day <= 11, do: ["Good morning!"], else: []) ++
      (if time_of_day >= 7, do: ["Good evening!"], else: [])

    "#{Enum.random(greetings)} Time to update your health journal!"
  end
end
