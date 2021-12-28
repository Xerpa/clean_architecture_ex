defmodule CleanArchitecture.Pagination do
  @moduledoc """
  Module that implements paginate function to be used for Repo queries.

  ## Fields:
  - `page_number`
  - `page_size`
  - `entries`
  - `total_entries`
  - `total_pages`
  """

  import Ecto.Query, warn: false

  defstruct [:page_number, :page_size, :entries, :total_entries, :total_pages]

  def paginate(query, repo, %{page: page, page_size: page_size}) do
    total_entries = get_total_entries(query, repo)
    total_pages = get_total_pages(total_entries, page_size)

    %__MODULE__{
      page_number: page,
      page_size: page_size,
      entries: get_entries(query, repo, page, total_pages, page_size),
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  defp get_total_entries(query, repo) do
    query
    |> exclude(:preload)
    |> exclude(:order_by)
    |> exclude(:select)
    |> repo.aggregate(:count, :id)
  end

  defp get_total_pages(total_entries, page_size) do
    (total_entries / page_size) |> Float.ceil() |> round()
  end

  defp get_entries(_query, _repo, page_number, total_pages, _page_size)
       when page_number > total_pages do
    []
  end

  defp get_entries(query, repo, page_number, _total_pages, page_size) do
    offset = page_size * (page_number - 1)

    query
    |> offset(^offset)
    |> limit(^page_size)
    |> repo.all()
  end
end
