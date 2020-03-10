defmodule HealthJournal.Repo.Migrations.InsertDays do
  use Ecto.Migration

  def change do
  	create table(:days) do
  		add :user_id, :integer, null: false
  		add :date, :date, null: false
  		add :sleep, :text
  		add :energy, :text
  		add :comfort, :text
  		add :food, :text
  		add :vitamins, :text
  		add :exercise, :text
  		timestamps()
  	end

  	create index(:days, :user_id)
  end
end
