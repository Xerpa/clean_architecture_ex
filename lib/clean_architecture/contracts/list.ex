defmodule CleanArchitecture.Contracts.List do
  @moduledoc """
  Input pattern necessary to perform a list use case.

  ## Fields:

  - `page` :: Used to paginate. (default 1, min 1)
  - `page_size` :: Used to paginate. (default 10, min 1, max 100)
  """

  import Ecto.Changeset

  @default_page 1
  @default_page_size 10

  def pagination_fields, do: [:page, :page_size]

  def validate_pagination(changeset) do
    changeset
    |> validate_number(:page, greater_than_or_equal_to: 1)
    |> validate_number(:page_size, greater_than_or_equal_to: 1, less_than_or_equal_to: 100)
  end

  def put_default_pagination_changes(changeset) do
    changeset
    |> put_default_page_changes()
    |> put_default_page_size_changes()
  end

  def put_default_page_changes(changeset) do
    page = get_change(changeset, :page)

    if page do
      changeset
    else
      put_change(changeset, :page, @default_page)
    end
  end

  def put_default_page_size_changes(changeset) do
    page_size = get_change(changeset, :page_size)

    if page_size do
      changeset
    else
      put_change(changeset, :page_size, @default_page_size)
    end
  end

  defmacro pagination_schema_fields do
    quote do
      Ecto.Schema.field(:page, :integer)
      Ecto.Schema.field(:page_size, :integer)
    end
  end

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      use CleanArchitecture.Contract

      import CleanArchitecture.Contracts.List
    end
  end
end
