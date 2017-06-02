defmodule OrderedSiblings.Repo.Migrations.CreateExampleSchemas do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :title, :string
    end

    create table(:posts) do
      add :thread_id, references(:threads)
      add :content, :text
      add :position, :integer, null: false, default: 0
    end
    # create unique_index(:posts, [:thread_id, :position])
  end
end
