module Schema.User (userType) where

import Prelude

import Context (Context)
import DB (User)
import GraphQL ((.>), (:>), (!#>))
import GraphQL as GQL

userType :: GQL.ObjectType Context User
userType = GQL.objectType "User"
  .> "A user in the system."
  :> GQL.field "id" GQL.id
    .> "A unique id for this user."
    !#> _.id >>> show
  :> GQL.field "name" GQL.string
    .> "The name of this user."
    !#> _.name
  :> GQL.field "email" GQL.string
    .> "The email of the user."
    !#> _.email
