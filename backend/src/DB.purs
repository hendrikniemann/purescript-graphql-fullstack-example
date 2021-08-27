module DB
  ( Todo
  , User
  , loadAllTodos
  , loadTodosByUserId
  , loadTodoById
  , createTodo
  , updateTodo
  , loadUserById
  , loadAllUsers
  ) where

import Prelude

import Control.Monad.Except (runExcept, throwError)
import Data.Array (head)
import Data.Array as Array
import Data.DateTime (DateTime)
import Data.Either (Either(..), either, fromRight')
import Data.Formatter.DateTime (Formatter, format, parseFormatString, unformat)
import Data.List.NonEmpty as NonEmptyList
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import Data.Traversable (traverse)
import Effect.Aff (Aff, error)
import Foreign (F, Foreign, ForeignError(..), fail, readArray, readInt, readNullOrUndefined, readString, renderForeignError, unsafeToForeign)
import Foreign.Index (readProp)
import Partial.Unsafe (unsafeCrashWith)
import SQLite3 (DBConnection, queryDB)

type Todo =
  { id :: Int
  , title :: String
  , createdAt :: DateTime
  , completedAt :: Maybe DateTime
  }

type User =
  { id :: Int
  , name :: String
  , email :: String
  , createdAt :: DateTime
  }

liftExcept :: forall a. F a -> Aff a
liftExcept ex = case runExcept ex of
  Left errors -> throwError $ error $ renderForeignError $ NonEmptyList.head errors
  Right val -> pure val

databaseDateFormat ∷ Formatter
databaseDateFormat = parseFormatString "YYYY-MM-DD HH:mm:ss" # fromRight' unknownFormat
  where
    unknownFormat = (\_ -> unsafeCrashWith "Could not parse DB datetime format.")

readDateTime :: Foreign -> F DateTime
readDateTime val = readString val >>= (either (fail <<< ForeignError) pure <<< parseDateTime)
  where
    parseDateTime :: String -> Either String DateTime
    parseDateTime = unformat databaseDateFormat

readLastInsertRow :: Foreign -> F Int
readLastInsertRow val = do
  arr <- readArray val
  case head arr of
    Nothing -> fail $ ForeignError "No rows returned for last_insert_rowid()"
    Just firstRow -> readInt =<< readProp "last_insert_rowid()" firstRow

toDateString :: DateTime -> String
toDateString = format databaseDateFormat

readTodo :: Foreign -> F Todo
readTodo obj = ado
  id <- readInt =<< readProp "id" obj
  title <- readString =<< readProp "title" obj
  createdAt <- readDateTime =<< readProp "created_at" obj
  completedAt <- traverse readDateTime =<< readNullOrUndefined =<< readProp "completed_at" obj
  in { id, title, createdAt, completedAt }

readUser :: Foreign -> F User
readUser obj = ado
  id <- readInt =<< readProp "id" obj
  name <- readString =<< readProp "name" obj
  email <- readString =<< readProp "email" obj
  createdAt <- readDateTime =<< readProp "created_at" obj
  in { id, name, email, createdAt }

loadAllTodos :: DBConnection -> Aff (Array Todo)
loadAllTodos connection = do
  res <- queryDB connection "SELECT * FROM todo" []
  liftExcept $ readArray res >>= traverse readTodo

loadTodosByUserId :: Int -> DBConnection -> Aff (Array Todo)
loadTodosByUserId userId connection = do
  res <- queryDB connection "SELECT * FROM todo WHERE user_id = ?" [unsafeToForeign userId]
  liftExcept $ readArray res >>= traverse readTodo

loadTodoById :: Int -> DBConnection -> Aff (Maybe Todo)
loadTodoById id connection = do
  res <- queryDB connection "SELECT * FROM todo WHERE id = ?" [unsafeToForeign id]
  arr <- liftExcept $ readArray res >>= traverse readTodo
  pure $ Array.head arr

createTodo :: { title :: String, userId :: Int, completedAt :: Maybe DateTime } -> DBConnection -> Aff Int
createTodo { title, userId, completedAt } connection = do
  let params =
        [ unsafeToForeign title
        , unsafeToForeign userId
        , unsafeToForeign $ toNullable $ map toDateString completedAt
        ]
  let query = """
          INSERT INTO todo (title, user_id, completed_at, created_at)
          VALUES (?, ?, ?, datetime());
        """
  _ <- queryDB connection query params
  res <- queryDB connection "SELECT last_insert_rowid();" []
  liftExcept $ readLastInsertRow res

updateTodo :: Int -> { title :: String, completedAt :: Maybe DateTime } -> DBConnection -> Aff Unit
updateTodo id { title, completedAt } connection = do
  let params =
        [ unsafeToForeign title
        , unsafeToForeign $ toNullable $ map toDateString completedAt
        , unsafeToForeign id
        ]
  void $
    queryDB
      connection
      "UPDATE todo SET title = ?, completed_at = ? WHERE id = ?"
      params

loadUserById :: Int -> DBConnection -> Aff (Maybe User)
loadUserById id connection = do
  res <- queryDB connection "SELECT * FROM user WHERE id = ?" [unsafeToForeign id]
  arr <- liftExcept $ readArray res >>= traverse readUser
  pure $ Array.head arr

loadAllUsers :: DBConnection -> Aff (Array User)
loadAllUsers connection = do
  res <- queryDB connection "SELECT * FROM user" []
  liftExcept $ readArray res >>= traverse readUser
