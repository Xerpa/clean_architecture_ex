defmodule CleanArchitecture.ContractTest do
  use ExUnit.Case, async: true

  alias CleanArchitecture.Contract

  describe "dummy/0" do
    test "returns 2" do
      assert Contract.dummy() == 2
    end
  end
end
