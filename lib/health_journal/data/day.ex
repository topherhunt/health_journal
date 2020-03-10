defmodule HealthJournal.Data.Day do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias HealthJournal.Data

  schema "days" do
    belongs_to :user, Data.User
    field :date, :date
    field :sleep, :text
    field :energy, :text
    field :comfort, :text
    field :food, :text
    field :vitamins, :text
    field :exercise, :text
    timestamps()
  end

  def changeset(struct, params, :owner) do
    struct
    |> cast(params, [:sleep, :energy, :comfort, :food, :vitamins, :exercise])
    |> validate_required([:user_id, :date])
  end

  #
  # Filters
  #

  def filter(orig_query \\ __MODULE__, filters) when is_list(filters) do
    Enum.reduce(filters, orig_query, fn {k, v}, query -> filter(query, k, v) end)
  end

  def filter(query, :id, id), do: where(query, [t], t.id == ^id)
  def filter(query, :user, user), do: where(query, [t], t.user_id == ^user.id)
end
