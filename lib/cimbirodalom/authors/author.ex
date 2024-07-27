defmodule Cimbirodalom.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :img_path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :img_path, :description])
    |> validate_required([:name, :img_path, :description])
    |> build_slug()
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end

  defp build_slug(changeset) do
    if title = get_field(changeset, :name) do
      put_change(changeset, :slug, Slug.slugify(title))
    else
      changeset
    end
  end
end
