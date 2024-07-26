defmodule Cimbirodalom.Repo.Migrations.CreateArticles do
  use Ecto.Migration


  @type_name :article_status

  def change do
    execute(
      """
      CREATE TYPE #{@type_name}
        AS ENUM ('draft','published','archived')
      """,
      "DROP TYPE #{@type_name}"
     )

    create table(:articles) do
      add :title, :text
      add :slug, :text
      add :subtitle, :text
      add :created_by, references(:admins, on_delete: :nilify_all)
      add :status, @type_name, null: false, default: "draft"

      timestamps(type: :utc_datetime)
    end

    create index(:articles, [:slug])
    create unique_index(:articles, [:title, :status])
    create unique_index(:articles, [:slug, :status])
    create index(:articles, [:created_by])
  end
end
