defmodule Cimbirodalom.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :slug, :string
    field :subtitle, :string
    field :created_by, :id
    field :status, Ecto.Enum, values: [:draft, :published, :archived], default: :draft
    has_one :content, Cimbirodalom.Articles.Content, where: [content_id: nil]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :subtitle, :status])
    |> validate_subset(:status, [:draft, :published, :archived])
    |> validate_required([:title, :subtitle])
    |> build_slug()
    |> unique_constraint([:title, :status])
    |> cast_assoc(:content, with: &Cimbirodalom.Articles.Content.changeset/2)
  end

  defp build_slug(changeset) do
    if title = get_field(changeset, :title) do
      put_change(changeset, :slug, Slug.slugify(title))
    else
      changeset
    end
  end
end
