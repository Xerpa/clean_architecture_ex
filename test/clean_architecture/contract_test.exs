defmodule CleanArchitecture.ContractTest do
  use CleanArchitecture.TestCase, async: true

  alias CleanArchitecture.Contract
  alias CleanArchitecture.Support.ContractMock

  @valid_attrs %{
    name: "name",
    last_name: "last_name",
    other: "other"
  }
  @valid_string_keys_attrs %{
    "name" => "name",
    "last_name" => "last_name",
    "other" => "other"
  }

  describe "validate_required_if_attribute_is_present/3" do
    test "returns valid changeset when all attributes are present" do
      changeset =
        @valid_attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, @valid_attrs)

      assert changeset.valid?
    end

    test "returns valid changeset when all attributes are present and keys are string" do
      changeset =
        @valid_string_keys_attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, @valid_string_keys_attrs)

      assert changeset.valid?
    end

    test "returns error when attribute is present but is nil" do
      attrs = %{@valid_attrs | other: nil}

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).other
    end

    test "returns error when attribute is present but is an empty string" do
      attrs = Map.put(@valid_string_keys_attrs, "other", "")

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).other
    end

    test "returns valid changeset when attribute is present and is filled" do
      attrs = %{@valid_attrs | other: "filled"}

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      assert changeset.valid?
    end

    test "returns valid changeset when attribute is not present" do
      attrs = Map.delete(@valid_attrs, :other)

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      assert changeset.valid?
    end

    test "returns valid changeset when all attributes are present, keys are string and required fields is a list" do
      changeset =
        @valid_string_keys_attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present([:other], @valid_string_keys_attrs)

      assert changeset.valid?
    end

    test "returns error when attribute is present but is nil and required fields is a list" do
      attrs = %{@valid_attrs | other: nil}

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).other
    end

    test "returns error when attribute is present but is an empty string and required fields is a list" do
      attrs = Map.put(@valid_string_keys_attrs, "other", "")

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      refute changeset.valid?

      assert "can't be blank" in errors_on(changeset).other
    end

    test "returns valid changeset when attribute is present and is filled and required fields is a list" do
      attrs = %{@valid_attrs | other: "filled"}

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      assert changeset.valid?
    end

    test "returns valid changeset when attribute is not present and required fields is a list" do
      attrs = Map.delete(@valid_attrs, :other)

      changeset =
        attrs
        |> ContractMock.changeset()
        |> Contract.validate_required_if_attribute_is_present(:other, attrs)

      assert changeset.valid?
    end
  end

  describe "validate_input/1" do
    test "returns error when is invalid" do
      assert {:error,
              %Ecto.Changeset{
                params: %{},
                required: [:name],
                types: %{last_name: :string, name: :string, other: :string, nested: _nested},
                errors: [name: {"can't be blank", [validation: :required]}],
                data: %ContractMock{}
              }} = ContractMock.validate_input(%{})
    end

    test "returns input changes when is valid" do
      assert ContractMock.validate_input(%{name: "Foo"}) ==
               {:ok, %{name: "Foo"}}
    end

    test "returns input changes with nested when is valid" do
      assert ContractMock.validate_input(%{name: "Foo", nested: %{name: "Bar", foo: "bar"}}) ==
               {:ok, %{name: "Foo", nested: %{name: "Bar"}}}
    end

    test "returns input changes with nested list when is valid" do
      assert ContractMock.validate_input(%{name: "Foo", nested_list: [%{name: "Bar", foo: "bar"}]}) ==
               {:ok, %{name: "Foo", nested_list: [%{name: "Bar"}]}}
    end
  end
end
