module Schema.Viewer (viewerType) where

import Prelude

import Context (Context)
import DB (loadTodosByUserId, loadUserById)
import GraphQL.Type ((.>), (:>), (!!>))
import GraphQL.Type as GQL
import Schema.Todo (todoType)
import Schema.User (userType)
import Util (getUserIdOrThrow, liftDbFunction)

viewerType :: GQL.ObjectType Context Unit
viewerType = GQL.objectType "Viewer"
  .> "All data scoped to the current viewer."
  :> GQL.nullableField "user" userType
    .> "The user object that belongs to this viewer."
    !!> (\_ -> do
      userId <- getUserIdOrThrow
      liftDbFunction $ loadUserById userId
    )
  :> GQL.listField "todos" todoType
    .> "The todos that this viewer has access to."
    !!> (\_ -> do
      userId <- getUserIdOrThrow
      liftDbFunction $ loadTodosByUserId userId
    )