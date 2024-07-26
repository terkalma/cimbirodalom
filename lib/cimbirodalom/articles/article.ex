defmodule Cimbirodalom.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :slug, :string
    field :subtitle, :string
    field :created_by, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :slug, :subtitle])
    |> validate_required([:title, :slug, :subtitle])
    |> unique_constraint(:slug)
  end
end
