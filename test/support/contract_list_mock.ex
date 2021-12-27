defmodule CleanArchitecture.Support.ContractListMock do
  @moduledoc """
  Input pattern necessary to perform a list action.
  Used for testing pourpouses.

  ## Fields:
  - `page`
  - `page_size`
  - `some_required_field`
  """

  use CleanArchitecture.Contracts.List

  embedded_schema do
    pagination_schema_fields()
    field(:some_required_field, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, pagination_fields() ++ [:some_required_field])
    |> validate_required(pagination_fields() ++ [:some_required_field])
    |> validate_pagination()
  end
end
