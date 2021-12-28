defmodule CleanArchitecture.Support.RepoMock do
  @moduledoc """
  This module is used to mock a Repo to test pagination.
  """

  @doc false
  def aggregate(_query, :count, _field), do: 0

  @doc false
  def all(_query), do: []
end
