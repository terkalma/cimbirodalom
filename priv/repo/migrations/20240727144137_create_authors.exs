defmodule Cimbirodalom.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :text, null: false
      add :slug, :text, null: false
      add :img_path, :text
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:authors, [:slug])
    create unique_index(:authors, [:name])
  end
end
