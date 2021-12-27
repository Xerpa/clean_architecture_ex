defmodule CleanArchitecture.Contracts.ListTest do
  use CleanArchitecture.TestCase, async: true

  alias CleanArchitecture.Support.ContractListMock

  @valid_attrs %{
    page: 2,
    page_size: 15,
    some_required_field: Ecto.UUID.generate()
  }

  describe "changeset" do
    test "creates valid changeset when all parameters are valid" do
      changeset = ContractListMock.changeset(@valid_attrs)

      assert changeset.valid?
    end

    test "returns error when changeset is missing any required field" do
      changeset = ContractListMock.changeset(%{page: nil, page_size: nil})

      assert Enum.sort(changeset.errors) ==
               Enum.sort(
                 page: {"can't be blank", [validation: :required]},
                 page_size: {"can't be blank", [validation: :required]},
                 some_required_field: {"can't be blank", [validation: :required]}
               )
    end

    test "does not return error when page is above zero" do
      attrs = Map.put(@valid_attrs, :page, 1)
      changeset = ContractListMock.changeset(attrs)

      refute errors_on(changeset)[:page]
    end

    test "returns error when page is zero" do
      attrs = Map.put(@valid_attrs, :page, 0)
      changeset = ContractListMock.changeset(attrs)

      assert "must be greater than or equal to 1" in errors_on(changeset).page
    end

    test "returns error when page is negative" do
      attrs = Map.put(@valid_attrs, :page, -1)
      changeset = ContractListMock.changeset(attrs)

      assert "must be greater than or equal to 1" in errors_on(changeset).page
    end

    test "does not return error when page_size is above zero" do
      attrs = Map.put(@valid_attrs, :page_size, 1)
      changeset = ContractListMock.changeset(attrs)

      refute errors_on(changeset)[:page_size]
    end

    test "returns error when page_size is zero" do
      attrs = Map.put(@valid_attrs, :page_size, 0)
      changeset = ContractListMock.changeset(attrs)

      assert "must be greater than or equal to 1" in errors_on(changeset).page_size
    end

    test "does not return error when page_size is 100" do
      attrs = Map.put(@valid_attrs, :page_size, 100)
      changeset = ContractListMock.changeset(attrs)

      refute errors_on(changeset)[:page_size]
    end

    test "returns error when page_size is negative" do
      attrs = Map.put(@valid_attrs, :page_size, -1)
      changeset = ContractListMock.changeset(attrs)

      assert "must be greater than or equal to 1" in errors_on(changeset).page_size
    end

    test "returns error when page_size is above 100" do
      attrs = Map.put(@valid_attrs, :page_size, 101)
      changeset = ContractListMock.changeset(attrs)

      assert "must be less than or equal to 100" in errors_on(changeset).page_size
    end
  end
end
