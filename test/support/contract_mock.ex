defmodule CleanArchitecture.Support.ContractMock do
  @moduledoc """
  Input pattern necessary to perform an action.
  Used for testing pourpouses.

  ## Fields:
  - `name`
  - `last_name`
  - `other`
  """

  use CleanArchitecture.Contract

  embedded_schema do
    field(:name, :string)
    field(:last_name, :string)
    field(:other, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :last_name, :other])
    |> validate_required([:name])
  end
end
