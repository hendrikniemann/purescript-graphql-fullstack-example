module Schema.Todo where

import Prelude

import Context (Context)
import DB (Todo)
import Data.Maybe (isJust)
import GraphQL.Type ((:>), (!#>), (.>))
import GraphQL.Type as GQL
import GraphQL.Type.Scalar as GQLScalar
import Schema.DateTime (dateTimeType)

todoType :: GQL.ObjectType Context Todo
todoType = GQL.objectType "Todo"
  .> "Type for todos in the database."
  :> GQL.field "id" GQLScalar.id
    .> "The unique identifier of this todo."
    !#> _.id >>> show
  :> GQL.field "title" GQLScalar.string
    .> "The title for this todo. This is the only data attached to this todo."
    !#> _.title
  :> GQL.field "createdAt" dateTimeType
    .> "The date on which this todo was created."
    !#> _.createdAt
  :> GQL.nullableField "completedAt" dateTimeType
    .> "The date on which this todo was completed."
    !#> _.completedAt
  :> GQL.field "isCompleted" GQLScalar.boolean
    .> "The date on which this todo was completed."
    !#> _.completedAt >>> isJust
