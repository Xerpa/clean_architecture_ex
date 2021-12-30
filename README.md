# Clean Architecture Elixir Library

This library contains modules used to develop an Elixir Application using Clean Architecture.

## Installation

The package can be installed by adding `clean_architecture` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:clean_architecture, "~> 0.1.0"}
  ]
end
```

## Clean Architecture Layers

### Suggested structure

- lib/<your_app_name>/contracts
- lib/<your_app_name>/interactors
- lib/<your_app_name>/entities
- lib/<your_app_name>.ex (Bounded context) - You can have more bounded contexts if you have your app splitted into multiple business domains / contexts.

### Contract

Usually an application that uses Clean Architecture assumes that an Use Case flow always starts with an **input** that will be processed somehow and after that an **output** will be returned.

The **Contract** layer is responsible to do the first step of the **input** processing, discarding attributes that are not allowed for an specific Use Case and validating the allowed ones.

Contracts on this library are based on Ecto Schema to handle validations and declare the allowed attributes.

If the input is valid, the **Contract** will return the validated input to be able to be delivered to the **Interactors**, that is the next step of the Use Case excecution.

When the input is not valid, it will fail with a standard `{:error, %Ecto.Changeset{}}` response.

#### Declaring contracts

##### Simple contract

```elixir
defmodule MyAppName.Contracts.User.Create do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:name, :string)
    field(:last_name, :string)
    field(:other, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :last_name, :other])
    |> validate_required([:name])
  end
end
```

##### Nested contract

```elixir
defmodule MyAppName.Contracts.User.CreateBatch do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:some_field, :string)

    embeds_one(:meta, MyAppName.Contracts.User.CreateMeta)
    embeds_many(:users, MyAppName.Contracts.User.Create)
  end

  def changeset(%{} = attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = contract, %{} = attrs) do
    contract
    |> cast(attrs, [:some_field])
    |> cast_embed(:meta, required: true)
    |> cast_embed(:users, required: false)
    |> validate_required([:some_field])
  end
end

defmodule MyAppName.Contracts.User.CreateMeta do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:action_author, :string)
  end

  def changeset(%{} = attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = contract, %{} = attrs) do
    contract
    |> cast(attrs, [:action_author])
    |> validate_required([:action_author])
  end
end
```

#### List and Get contracts

Not always an Use Case will persist something. Sometimes we want just to retrieve some data to be showed in an interface or exposed to an API. This does not mean that this retrievals are not Business Use Cases and that we don't need to validate the inputs.

##### Get contract

```elixir
defmodule MyAppName.Contracts.User.Get do
  use CleanArchitecture.Contract

  embedded_schema do
    field :id, Ecto.UUID
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
```

##### List contract

In an Use Case that returns a list of something, we could have some filters that needs to be validated before the list excecution. Other common list behavior is to paginate this list, avoiding returning all the data.

**Pagination** sometimes are handled as a technical detail and the main motivation usually is to avoid performance issues, but Clean Architecture is about the business and not technical details, so why we need to be concerned about pagination if we are focusing on the business? The answer is simple, pagination is not only a technical detail, it often is a business rule or a software requirement. For the business problem your software is solving, it almost never makes sense to display a complete list in an interface on your system, it would not be readable.

That's why we implemented this as a common behavior on this Library, using some helper functions and an extension of a specific kind of contract, pagination attributes `page` and `page_size` will be handled by the list contract.

###### List contract example

```elixir
defmodule MyAppName.Contracts.User.List do
  use CleanArchitecture.Contracts.List

  embedded_schema do
    pagination_schema_fields()
    field(:some_field, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, pagination_fields() ++ [:some_field])
    |> put_default_pagination_changes()
    |> validate_required(pagination_fields() ++ [:some_field])
    |> validate_pagination()
  end
end
```

#### validate_input function

Is the function of the **Contract** responsible for the input validation. It calls the contract's `changeset` function and if the changeset is valid it returns the Ecto's changeset `changes` in a tuple (`{:ok, changeset_changes}`), otherwise the response will be an error tuple (`{:error, %Ecto.Changeset{}}`).

The validate_input function relies on the `changes` attribute to be able to go to the next step in the Clean Architecture flow using only what was informed on the original input map, discarding attribute keys that was not present. The main motivation behind this decision was to be able to excecute Use Cases that make partial updates, avoiding assuming that attributes that was not informed would be cleared of overwriten by defaults.

The same behavior is applied for nested attributes/contracts, instead of returning Ecto.Changeset or Contract Structs on the nested map structure, it will be appended to the external map using only the attributes informed, as long as these attributes are valid, otherwise the entire process will fail.

#### Using contracts

```elixir
input = %{name: "Foo"}

case MyAppName.Contracts.MyActionName.validate_input(input) do
  {:ok, validated_input} ->
    # Do something with the validated input

  {:error, %Ecto.Changeset{} = changeset} ->
    {:error, changeset}
end
```

### Interactor

Interactors consolidates all the business rules and Use Case steps after the input validation. It assumes that the input has already been validated and is responsible to return an output after the excecution that is usually the entity or entities changed on the process. Other relevant data from the excecution could also be added to the **output**.

The Interactor's output should follow the same pattern from **Contracts**. If the execution is successful, the response should be an :ok tuple (`{:ok, output}`), otherwise it should be an :error tuple (`{:error, %Ecto.Changeset{}}`).

#### Defining interactors

The example below is a simple `User Create` Use Case that does not have many business rules.

If you have more complex business rules, these rules should be added to the interactor pipeline.

```elixir
defmodule MyAppName.Interactors.User.Create do
  use CleanArchitecture.Interactor

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%{} = input) do
    input
    |> User.changeset()
    |> Repo.insert()
    |> do_something_after_the_user_is_persisted()
  end
end
```

#### List interactors

As well as list Contracts, the Clean Architecture Library has also helpers to do the pagination at Interactors. You need to import `CleanArchitecture.Pagination` module and after that you can use `paginate` function.

```elixir
defmodule MyAppName.Interactors.User.List do
  use CleanArchitecture.Interactor

  import CleanArchitecture.Pagination

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%{page: page, page_size: page_size} = input) do
    User
    |> paginate(Repo, %{page: page, page_size: page_size})
  end
end
```

### Entity

Represents a business entity. Is usually a struct based on Ecto Schema. It's attributes should be named according to business terms to achieve a common language between developers and business/product specialists (Ubiquitous Language).

#### Defining entities

```elixir
defmodule MyAppName.Entities.User do
  use CleanArchitecture.Entity

  schema "employees" do
    field :name, :string
    field :last_name, :string

    timestamps(type: :utc_datetime_usec)
  end

  # ...changeset
end
```

### Bounded context

Is responsible to expose all the domain/context Use Cases. It handles the input using a **Contract** and calls the **Interactor** responsible to excecute that action.

It's an interface between the business logic and the delivery mechanisms and other contexts.

It is also responsibility of the bounded context to make the input and output explicit.

Reading the bounded contexts of an application should give the developers the view of all Use Cases of the system, what they need to perform (input) and what they return (output).

#### Defining bounded contexts

```elixir
defmodule MyAppName do
  use CleanArchitecture.BoundedContext

  def create_user(input) do
    with {:ok, validated_input} <- Contracts.User.Create.validate_input(input),
         {:ok, %User{} = user} <- Interactors.User.Create.call(validated_input) do
      {:ok, user}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end
end
```

## Full CRUD example

### Bounded Context

```elixir
defmodule MyAppName do
  use CleanArchitecture.BoundedContext

  def get_user!(input) do
    case Contracts.User.Get.validate_input(input) do
      {:ok, validated_input} ->
        %User{} = Interactors.User.Get.call(validated_input)

      {:error, %Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def list_users(input) do
    case Contracts.User.List.validate_input(input) do
      {:ok, validated_input} ->
        %Pagination{entries: _, page_number: _, page_size: _, total_entries: _, total_pages: _} =
          Interactors.User.List.call(validated_input)

      {:error, %Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def create_user(input) do
    with {:ok, validated_input} <- Contracts.User.Create.validate_input(input),
         {:ok, %User{} = user} <- Interactors.User.Create.call(validated_input) do
      {:ok, user}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def update_user(input) do
    with {:ok, %{id: id} = validated_input} <- Contracts.User.Update.parse_input(input),
         %User{} = user <- get_user!(%{id: id}),
         {:ok, %User{} = user} <- Interactors.User.Update.call(user, validated_input) do
      {:ok, user}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def delete_user(input) do
    with {:ok, %{id: id} = validated_input} <- Contracts.User.Delete.parse_input(input),
         %User{} = user <- get_user!(%{id: id}),
         {:ok, %User{} = user} <- Interactors.User.Delete.call(user) do
      {:ok, user}
    else
      {:error, %Changeset{} = changeset} -> {:error, changeset}
    end
  end
end
```

### Entity

```elixir
defmodule MyAppName.Entities.User do
  use CleanArchitecture.Entity

  schema "users" do
    field :name, :string
    field :last_name, :string

    timestamps(type: :utc_datetime_usec)
  end

  def changeset do
    changeset(%__MODULE__{}, %{})
  end

  def changeset(%__MODULE__{} = user) do
    changeset(user, %{})
  end

  def changeset(%{} = attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = user, %{} = attrs) do
    user
    |> cast(attrs, [:name, :last_name])
    |> validate_required([:name, :last_name])
  end
end
```

### Interactors

```elixir
defmodule MyAppName.Interactors.User.Get do
  use CleanArchitecture.Interactor

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%{id: id}) do
    User
    |> Repo.get!(id)
  end
end
```

```elixir
defmodule MyAppName.Interactors.User.List do
  use CleanArchitecture.Interactor

  import CleanArchitecture.Pagination

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%{page: page, page_size: page_size} = input) do
    User
    |> filter_by_name(input)
    |> filter_by_last_name(input)
    |> order_by(asc: :name)
    |> paginate(Repo, %{page: page, page_size: page_size})
  end

  defp filter_by_name(query, %{name: name}) when not is_nil(name) do
    query
    |> where(name: ^name)
  end

  defp filter_by_name(query, _), do: query

  defp filter_by_last_name(query, %{last_name: last_name}) when not is_nil(last_name) do
    query
    |> where(last_name: ^last_name)
  end

  defp filter_by_last_name(query, _), do: query
end
```

```elixir
defmodule MyAppName.Interactors.User.Create do
  use CleanArchitecture.Interactor

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%{} = input) do
    input
    |> User.changeset()
    |> Repo.insert()
  end
end
```

```elixir
defmodule MyAppName.Interactors.User.Update do
  use CleanArchitecture.Interactor

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%User{} = user, %{} = input) do
    user
    |> User.changeset(input)
    |> Repo.update()
  end
end
```

```elixir
defmodule MyAppName.Interactors.User.Delete do
  use CleanArchitecture.Interactor

  alias MyAppName.Entities.User
  alias MyAppName.Repo

  def call(%User{} = user) do
    user
    |> Repo.delete()
  end
end
```

### Contracts

```elixir
defmodule MyAppName.Contracts.User.Get do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:id, Ecto.UUID)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
```

```elixir
defmodule MyAppName.Contracts.User.List do
  use CleanArchitecture.Contracts.List

  embedded_schema do
    pagination_schema_fields()
    field(:name, :string)
    field(:last_name, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, pagination_fields() ++ [:name, :last_name])
    |> put_default_pagination_changes()
    |> validate_required(pagination_fields())
    |> validate_pagination()
  end
end
```

```elixir
defmodule MyAppName.Contracts.User.Create do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:name, :string)
    field(:last_name, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :last_name])
    |> validate_required([:name, :last_name])
  end
end
```

```elixir
defmodule MyAppName.Contracts.User.Update do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:name, :string)
    field(:last_name, :string)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :last_name])
    |> validate_required_if_attribute_is_present([:name, :last_name])
  end
end
```

```elixir
defmodule MyAppName.Contracts.User.Delete do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:id, Ecto.UUID)
  end

  def changeset(%{} = attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id])
    |> validate_required([:id])
  end
end
```

