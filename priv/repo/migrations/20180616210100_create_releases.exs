defmodule ReleaseTime.Repo.Migrations.CreateReleases do
  use Ecto.Migration

  def change do
    create table(:releases) do
      add :repo_id, :integer
      add :name, :string

      timestamps()
    end

    create index(:releases, [:repo_id, :name], unique: true)
  end
end
