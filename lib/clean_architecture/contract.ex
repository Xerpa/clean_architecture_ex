defmodule CleanArchitecture.Contract do
  @moduledoc """
  Default functions for input pattern necessary to perform an action.
  """

  @doc """
  Validates required only when the attribute is present to the input.

  This ables us to update something partially,
  when the attribute cannot be nil or empty
  but the key is not required to be present at the input to perform the action.

  The following examples explore a scenario when last_name attribute is required if attribute is present.

  ## Examples
      iex> validate_required_if_attribute_is_present(%Ecto.Changeset{}, [:last_name], %{name: "Foo"})
      %Ecto.Changeset{valid?: true}

      iex> validate_required_if_attribute_is_present(%Ecto.Changeset{}, [:last_name], %{last_name: "Bar"})
      %Ecto.Changeset{valid?: true}

      iex> validate_required_if_attribute_is_present(%Ecto.Changeset{}, [:last_name], %{name: "Foo", last_name: "Bar"})
      %Ecto.Changeset{valid?: true}

      iex> validate_required_if_attribute_is_present(%Ecto.Changeset{}, [:last_name], %{name: "Foo", last_name: nil})
      %Ecto.Changeset{valid?: false}

      iex> validate_required_if_attribute_is_present(%Ecto.Changeset{}, [:last_name], %{name: "Foo", last_name: ""})
      %Ecto.Changeset{valid?: false}
  """
  def validate_required_if_attribute_is_present(changeset, fields, attrs) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, acc ->
      validate_required_if_attribute_is_present(acc, field, attrs)
    end)
  end

  def validate_required_if_attribute_is_present(changeset, field, attrs) when is_atom(field) do
    if Map.has_key?(attrs, Atom.to_string(field)) || Map.has_key?(attrs, field) do
      Ecto.Changeset.validate_required(changeset, field)
    else
      changeset
    end
  end

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import CleanArchitecture.Contract

      @primary_key false

      def validate_input(input) do
        input_changeset = changeset(input)

        if input_changeset.valid? do
          {:ok, input_changeset.changes}
        else
          {:error, input_changeset}
        end
      end
    end
  end
end
