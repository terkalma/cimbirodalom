defmodule Cimbirodalom.Repo.Migrations.CreateArticleContennts do
  use Ecto.Migration

  def change do
    create table(:article_contennts) do
      add :json_content, :jsonb, default: "{}"
      add :html_content, :text
      add :article_id, references(:articles, on_delete: {:nilify, [:article_id]})
      add :content_id, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:article_contennts, [:article_id])
    create index(:article_contennts, [:article_id, :content_id])
  end
end
