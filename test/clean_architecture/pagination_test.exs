defmodule CleanArchitecture.PaginationTest do
  use CleanArchitecture.TestCase, async: true

  import Mock

  alias CleanArchitecture.Pagination
  alias CleanArchitecture.Support.RepoMock
  alias CleanArchitecture.Support.SchemaMock

  describe "paginate/3" do
    test "paginates empty result" do
      query = SchemaMock
      input = %{page: 1, page_size: 10}

      assert %Pagination{
               entries: [],
               page_number: 1,
               page_size: 10,
               total_entries: 0,
               total_pages: 0
             } == Pagination.paginate(query, RepoMock, input)
    end

    test "paginates non empty result" do
      query = SchemaMock
      input = %{page: 1, page_size: 3}
      entries = [%SchemaMock{}, %SchemaMock{}, %SchemaMock{}]

      with_mock RepoMock,
        aggregate: fn _query, :count, :id -> 3 end,
        all: fn query ->
          assert %Ecto.Query.QueryExpr{
                   expr: {:^, [], [0]},
                   file: _,
                   line: _,
                   params: [{3, :integer}]
                 } = query.limit

          assert %Ecto.Query.QueryExpr{
                   expr: {:^, [], [0]},
                   file: _,
                   line: _,
                   params: [{0, :integer}]
                 } = query.offset

          [entries]
        end do
        assert %Pagination{
                 entries: [entries],
                 page_number: 1,
                 page_size: 3,
                 total_entries: 3,
                 total_pages: 1
               } == Pagination.paginate(query, RepoMock, input)
      end
    end

    test "excludes preload, order_by and select from count query" do
      query = SchemaMock |> preload(:abc) |> select([t], t.name) |> order_by(asc: :name)
      input = %{page: 1, page_size: 3}
      entries = [%SchemaMock{}, %SchemaMock{}, %SchemaMock{}]

      with_mock RepoMock,
        aggregate: fn query, :count, :id ->
          assert query.preloads == []
          assert query.order_bys == []
          assert query.select == nil
          3
        end,
        all: fn _query -> [entries] end do
        assert %Pagination{
                 entries: [entries],
                 page_number: 1,
                 page_size: 3,
                 total_entries: 3,
                 total_pages: 1
               } == Pagination.paginate(query, RepoMock, input)
      end
    end
  end
end
