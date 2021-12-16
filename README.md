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

### Interactor

Interactors consolidates all the business rules and Use Case steps. It assumes that the input has already been validated and is responsible to return an output after the excecution.

### Entity

Represents a business entity. Is usually a struct based on Ecto. It's attributes are names according to business terms to achieve a common language between developers and business/product specialists (Ubiquitous Language).

### Bounded context

Is responsible to expose all the domain/context Use Cases. It handles the input using a contract and calls the interactor responsible to excecute that action.

It's an interface between the business logic and the delivery mechanisms and other contexts.

It is also responsibility of the bounded context to make the input and output explicit.
