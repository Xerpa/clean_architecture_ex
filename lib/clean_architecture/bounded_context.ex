defmodule CleanArchitecture.BoundedContext do
  @moduledoc """
  Default functions and behavior for bounded contexts.
  """

  defmacro __using__(_) do
    quote do
      alias Ecto.Changeset

      alias __MODULE__.Contracts
      alias __MODULE__.Entities
      alias __MODULE__.Interactors

      alias CleanArchitecture.Pagination
    end
  end
end
