# Changelog

## 0.1.0 (2021-12-29)

First release.

### Features

* **[Contract]** Module to be used on application contracts. It uses Ecto for validations.
* **[Contract]** Handling nested attributes.
* **[Contract]** Implemented `validate_input` function to be used to start the validation process and receive a validated input to be passed to interactors.
* **[Contract]** Helper function `validate_required_if_attribute_is_present` for contracts that need to do partial updates. It will validate requireness only if the attribute key is present to the initial map input.
* **[Contract]** Contracts are Ecto Schemas that comes with all Ecto defaults. Using the Contract module sets a new default overwriting Ecto's behavior. Contracts not always need primary keys, so the default for this module is that an `id` field needs to be declared explicitly if you need that your contract handles `id` attribute. Problably you will want to do this in `Update` or `Delete` use cases, but not in `Create`.
* **[Entity]** Using this module for now just sets up Ecto Schema and Changeset. New behaviors could be added in the future.
* **[Interactor]** Using this module for now just imports Ecto Query. New behaviors could be added in the future.
* **[BoundedContext]** Using this module for now just sets up some aliases. New behaviors could be added in the future.
