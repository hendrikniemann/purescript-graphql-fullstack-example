module Schema.User (userType) where

import Prelude

import Context (Context)
import DB (User)
import GraphQL.Type ((.>), (:>), (!#>))
import GraphQL.Type as GQL
import GraphQL.Type.Scalar as GQLScalar

userType :: GQL.ObjectType Context User
userType = GQL.objectType "User"
  .> "A user in the system."
  :> GQL.field "id" GQLScalar.id
    .> "A unique id for this user."
    !#> _.id >>> show
  :> GQL.field "name" GQLScalar.string
    .> "The name of this user."
    !#> _.name
  :> GQL.field "email" GQLScalar.string
    .> "The email of the user."
    !#> _.email
