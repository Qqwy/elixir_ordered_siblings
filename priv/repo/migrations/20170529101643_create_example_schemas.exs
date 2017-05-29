defmodule OrderedSiblings.Repo.Migrations.CreateExampleSchemas do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :title, :string
    end

    create table(:posts) do
      add :thread_id, references(:threads)
      add :content, :text
      add :order, :integer, null: false, default: -1
    end
    create index(:posts, [:thread_id, :order])
  end
end
