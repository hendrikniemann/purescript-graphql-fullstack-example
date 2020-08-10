module Main where

import Prelude

import Auth as Auth
import Control.Alt ((<|>))
import Control.Monad.State (evalStateT)
import Data.Argonaut (Json, stringify, jsonParser, decodeJson, (.:), (.:?))
import Data.Array (uncons)
import Data.Either (Either(..))
import Data.Map (Map, fromFoldableWithIndex)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Traversable (traverse)
import Dotenv as Dotenv
import Effect (Effect)
import Effect.Aff (catchError, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Foreign.Object (Object) as FO
import GraphQL (graphql)
import HTTPure as HTTPure
import HTTPure.Lookup ((!!))
import Node.Process (lookupEnv)
import SQLite3 (DBConnection, newDB)
import Schema (schema)
import Util (noteME)

type GraphQLParams =
  { query :: String
  , variables :: Maybe (Map String Json)
  , operationName :: Maybe String
  }

decodeParams :: Json -> Either String GraphQLParams
decodeParams json = do
  obj <- decodeJson json
  query <- obj .: "query"
  variables <- map fromFoldableWithIndex <$>
    ((obj .:? "variables") :: Either String (Maybe (FO.Object Json)))
  operationName <- obj .:? "operationName"
  pure $ { query, variables, operationName }

responseHeaders :: HTTPure.Headers
responseHeaders = HTTPure.header "Content-Type" "application/json"

createRouter :: DBConnection -> HTTPure.Request -> HTTPure.ResponseM
createRouter connection { body, method: HTTPure.Post, path: [ "graphql" ], headers } =
  case jsonParser body >>= decodeParams of
    Left error -> HTTPure.badRequest error
    Right { query, variables, operationName } -> do
      let authHeader = headers !! "Authorization" <|> headers !! "authorization"
      let vars = fromMaybe mempty variables
      let execution = graphql schema query vars operationName unit
      userId <- liftEffect $ traverse Auth.validateToken authHeader
      result <- evalStateT execution { connection, userId }
      HTTPure.ok' responseHeaders $ stringify result
createRouter _ _ = HTTPure.notFound

loggingMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) -> HTTPure.Request -> HTTPure.ResponseM
loggingMiddleware router request = do
  liftEffect $ Console.log $ "-> " <> show request.method <> " " <> showPath request.path
  response <- router request
  liftEffect $ Console.log $ "<- " <> show response.status
  pure response
    where
      showPath :: Array String -> String
      showPath x
        | Just { head, tail } <- uncons x = showPath tail <> "/" <> head
        | otherwise = ""

main :: Effect Unit
main = catchError server (show >>> Console.log)
  where
    server = launchAff_ do
      _ <- Dotenv.loadFile
      dbUri <- liftEffect $
        lookupEnv "DATABASE_URI" >>= noteME "Environment variable DATABASE_URI not found!"
      conn <- newDB dbUri
      let router = loggingMiddleware $ createRouter conn
      liftEffect $ HTTPure.serve 8080 router $ Console.log "Running server..."
