module Schema.Mutation where

import Prelude

import Context (Context, getContext)
import DB (Todo, createTodo, loadTodoById, updateTodo)
import Data.DateTime (DateTime)
import Data.Int (fromString)
import Data.Maybe (Maybe(..), isJust)
import Data.Symbol (SProxy(..))
import Data.Traversable (foldl, sequence)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import GraphQL ((!#>), (!>), (.>), (:>), (?>))
import GraphQL as GQL
import Schema.Todo (todoDraftType, todoType)
import Util (currentDateTime, getUserIdOrThrow, noteME)

mutationType :: GQL.ObjectType Context Unit
mutationType = GQL.objectType "Mutation"
  .> "The main Mutation object, entrance for all mutations."
  :> GQL.field "completeTodo" completeTodoResult
    .> "Complete a todo."
    ?> GQL.arg GQL.id (SProxy :: SProxy "id")
      .> "The id of the todo that should be set to complete."
    !> completeTodoResolver
  :> GQL.field "uncompleteTodo" uncompleteTodoResult
    .> "Undo the completion of a todo."
    ?> GQL.arg GQL.id (SProxy :: SProxy "id")
      .> "The id of the todo that should no longer be set to complete."
    !> updateTodoCompletedAt Nothing
  :> GQL.field "createTodo" createTodoResult
    .> "Create a new Todo."
    ?> GQL.arg todoDraftType (SProxy :: SProxy "draft")
      .> "A draft version of the new todo."
    !> createTodoResolver
    where
      completeTodoResolver :: { id :: String } -> Unit -> Context (Maybe Todo)
      completeTodoResolver args _ = do
        createdAt <- liftEffect $ Just <$> currentDateTime
        updateTodoCompletedAt createdAt args unit

      createTodoResolver :: { draft :: { title :: String } } -> Unit -> Context (Maybe Todo)
      createTodoResolver { draft } _ = do
        context <- getContext
        userId <- getUserIdOrThrow
        liftAff do
          id <- createTodo { title: draft.title, userId, completedAt: Nothing } context.connection
          loadTodoById id context.connection

      updateTodoCompletedAt :: Maybe DateTime -> { id :: String } -> Unit -> Context (Maybe Todo)
      updateTodoCompletedAt completedAt { id } affConn = do
        context <- getContext
        parsedId <- noteME "Parameter 'id' must be a valid integer value!" $ fromString id
        todo <- liftAff $ loadTodoById parsedId context.connection
        sequence $ todo <#> \t -> liftAff do
          updateTodo t.id { title: t.title, completedAt } context.connection
          pure $ t { completedAt = completedAt }

mutationResultFields :: Array (GQL.Field Context (Maybe Todo) () ())
mutationResultFields =
  [ GQL.field "success" GQL.boolean
      .> "Indicates whether this mutation was successful."
      !#> isJust
  , GQL.nullableField "todo" todoType
      .> "If the mutation was successful the updated todo is returned here."
      !#> identity
  ]

completeTodoResult :: GQL.ObjectType Context (Maybe Todo)
completeTodoResult = foldl GQL.withField t mutationResultFields
  where
    t = GQL.objectType "CompleteTodoResult" .> "Result type for `completeTodo` mutation."

uncompleteTodoResult :: GQL.ObjectType Context (Maybe Todo)
uncompleteTodoResult = foldl GQL.withField t mutationResultFields
  where
    t = GQL.objectType "UncompleteTodoResult" .> "Result type for `uncompleteTodo` mutation."

createTodoResult :: GQL.ObjectType Context (Maybe Todo)
createTodoResult = foldl GQL.withField t mutationResultFields
  where
    t = GQL.objectType "CreateTodoResult" .> "Result type for `createTodo` mutation."
