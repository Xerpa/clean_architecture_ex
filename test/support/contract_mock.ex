defmodule CleanArchitecture.Support.ContractMock do
  @moduledoc """
  Input pattern necessary to perform an action.
  Used for testing pourpouses.

  ## Fields:
  - `name`
  - `last_name`
  - `other`
  - `nested`
  """

  use CleanArchitecture.Contract

  embedded_schema do
    field(:name, :string)
    field(:last_name, :string)
    field(:other, :string)
    field(:list_of_strings, {:array, :string})

    embeds_one(:nested, CleanArchitecture.Support.ContractMock)
    embeds_many(:nested_list, CleanArchitecture.Support.ContractMock)
  end

  def changeset(%{} = attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = mock, %{} = attrs) do
    mock
    |> cast(attrs, [:name, :last_name, :other, :list_of_strings])
    |> cast_embed(:nested, required: false)
    |> cast_embed(:nested_list, required: false)
    |> validate_required([:name])
  end
end
