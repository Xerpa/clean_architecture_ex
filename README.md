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

Contract is responsible to parse and validate the Use Case input. It is based on Ecto Schema to handle validations. If the input is valid, the Use Case will be excecuted, otherwise it will fail with a standard `{:error, %Ecto.Changeset{}}` response.

#### Defining contracts

##### Default contract

```elixir
defmodule MyAppName.Contracts.Users.Create do
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
defmodule MyAppName.Contracts.Users.CreateBatch do
  use CleanArchitecture.Contract

  embedded_schema do
    field(:some_field, :string)

    embeds_many(:users, MyAppName.Contracts.Users.Create)
  end

  def changeset(%{} = attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = contract, %{} = attrs) do
    contract
    |> cast(attrs, [:some_field])
    |> cast_embed(:users, required: false)
    |> validate_required([:some_field])
  end
end
```

##### List contract

```elixir
defmodule MyAppName.Contracts.Users.List do
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

#### Using

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

Interactors consolidates all the business rules and Use Case steps. It assumes that the input has already been validated and is responsible to return an output after the excecution.

### Entity

Represents a business entity. Is usually a struct based on Ecto. It's attributes are names according to business terms to achieve a common language between developers and business/product specialists (Ubiquitous Language).

### Bounded context

Is responsible to expose all the domain/context Use Cases. It handles the input using a contract and calls the interactor responsible to excecute that action.

It's an interface between the business logic and the delivery mechanisms and other contexts.

It is also responsibility of the bounded context to make the input and output explicit.
