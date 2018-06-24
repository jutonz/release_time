defmodule ReleaseTime.Release do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias ReleaseTime.{Release, Repo}

  @type t :: %__MODULE__{}

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

  @spec get_by_name(String.t()) :: {:ok, Release.t()} | {:error, String.t()}
  def get_by_name(release_name) do
    query = from(
      r in Release,
      where: r.name == ^release_name
    )

    case query |> Repo.one do
      release = %Release{} -> {:ok, release}
      _ -> {:error, "Could not find release with name #{release_name}"}
    end
  end
end
