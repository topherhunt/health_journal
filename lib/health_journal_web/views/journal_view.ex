defmodule HealthJournalWeb.JournalView do
  use HealthJournalWeb, :view

  def newlines_to_bullets(string) do
    (string || "") |> String.replace("\n", " • ") |> raw()
  end
end
