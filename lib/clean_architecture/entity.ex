defmodule CleanArchitecture.Entity do
  @moduledoc """
  Default functions and behavior for entities.
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
    end
  end
end
