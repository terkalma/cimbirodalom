defmodule Cimbirodalom.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :text
      add :slug, :text
      add :subtitle, :text
      add :created_by, references(:admins, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:articles, [:slug])
    create index(:articles, [:created_by])
  end
end
