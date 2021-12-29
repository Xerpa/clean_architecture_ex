defmodule CleanArchitecture.Interactor do
  @moduledoc """
  Default functions and behavior for interactors.
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query, warn: false
    end
  end
end
