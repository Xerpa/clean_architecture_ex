defmodule CleanArchitecture.Support.SchemaMock do
  @moduledoc """
  Schema mock.
  Used for testing pourpouses.

  ## Fields:
  - `name`
  - `last_name`
  - `other`
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "mocks" do
    field(:name, :string)
    field(:last_name, :string)
    field(:other, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :last_name, :other])
    |> validate_required([:name, :last_name])
  end
end
