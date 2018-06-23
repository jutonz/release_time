defmodule ReleaseTime.Release do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias ReleaseTime.{Release, Repo}

  schema "releases" do
    field :repo_id, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(release, attrs \\ %{}) do
    release
    |> cast(attrs, [:repo_id, :name])
    |> validate_required([:repo_id, :name])
    |> unique_constraint(:name)
  end

  def by_repo_id(repo_id, limit \\ 50, offset \\ 0) do
    query = from(
      r in Release,
      where: r.repo_id == ^repo_id,
      order_by: r.name,
      offset: ^offset,
      limit: ^limit
    )
    {:ok, Repo.all(query)}
  end

  def get_by_name(release_name) do
    query = from(
      r in Release,
      where: r.name == ^release_name
    )

    {:ok, query |> Repo.one}
  end
end
