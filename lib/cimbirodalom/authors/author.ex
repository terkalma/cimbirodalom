defmodule Cimbirodalom.Authors.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :name, :string
    field :description, :string
    field :slug, :string
    field :img_data, :map
    field :locked_for_asset_update_at, :utc_datetime
    field :image_data, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  # def image_path(%Author{} = author) do
  #   author.current_img_key
  #   |> Path.join(author.slug)
  # end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name, :img_data, :image_data, :description])
    |> validate_required([:name, :description])
    |> build_slug()
    |> unsafe_validate_unique(:name, Cimbirodalom.Repo)
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end

  defp build_slug(changeset) do
    if title = get_field(changeset, :name) do
      put_change(changeset, :slug, Slug.slugify(title))
    else
      changeset
    end
  end
end
