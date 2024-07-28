defmodule Cimbirodalom.Repo.Migrations.CreateAuthors do
  use Ecto.Migration

  def change do
    create table(:authors) do
      add :name, :text, null: false
      add :slug, :text, null: false
      add :img_data, :jsonb, default: "{}"
      add :description, :text
      add :locked_for_asset_update_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:authors, [:slug])
    create unique_index(:authors, [:name])
  end
end
