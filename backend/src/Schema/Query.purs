module Schema.Query where

import Prelude

import Context (Context, getContext)
import DB (loadAllTodos, loadTodoById)
import Data.Int (fromString)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (error, throwError)
import Effect.Aff.Class (liftAff)
import GraphQL.Type ((!!>), (!>), (.>), (:>), (?>))
import GraphQL.Type as GQL
import GraphQL.Type.Scalar as GQLScalar
import Schema.Todo (todoType)
import Schema.Viewer (viewerType)
import Util (liftDbFunction)


queryType :: GQL.ObjectType Context Unit
queryType = GQL.objectType "Query"
  .> "The main Query object, entrance for all queries."
  :> GQL.field "viewer" viewerType
    .> "A scope object type that contains all the viewer related fields."
  :> GQL.listField "todos" todoType
    .> "Load all todos from the database."
    !!> (\_ -> liftDbFunction loadAllTodos)
  :> GQL.nullableField "todo" todoType
    .> "Load a single todo from the database by its unique id."
    ?> GQL.arg GQLScalar.id (SProxy :: _ "id")
      .> "The id of the todo that should be loaded."
    !> (\{ id } _ -> case fromString id of
          Nothing -> throwError $ error $ "Value for id must be a parseable Integer."
          Just intId -> do
            context <- getContext
            liftAff $ loadTodoById intId context.connection
       )
