defmodule HealthJournal.Repo.Migrations.AddOpenReflectionsToDays do
  use Ecto.Migration

  def change do
    alter table(:days) do
      add :reflections, :text
    end
  end
end
