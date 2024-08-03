defmodule Cimbirodalom.Articles.Content do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_contennts" do
    field :json_content, :map, default: %{}
    field :html_content, :string
    field :article_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(content, attrs) do
    content
    |> cast(attrs, [:json_content, :html_content])
    |> validate_required([:json_content])
  end
end
