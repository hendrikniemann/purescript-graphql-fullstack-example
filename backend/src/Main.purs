module Main where

import Prelude

import Auth as Auth
import Control.Alt ((<|>))
import Control.Monad.State (evalStateT)
import Data.Argonaut (Json, JsonDecodeError, decodeJson, jsonParser, printJsonDecodeError, stringify, (.:), (.:?))
import Data.Array (uncons)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Map (Map, fromFoldableWithIndex, empty)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (drop)
import Data.String.Utils (startsWith)
import Data.Traversable (traverse)
import Data.Tuple.Nested ((/\))
import Dotenv as Dotenv
import Effect (Effect)
import Effect.Aff (catchError, error, launchAff_, throwError)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
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

decodeParams :: Json -> Either JsonDecodeError GraphQLParams
decodeParams json = do
  obj <- decodeJson json
  query <- obj .: "query"
  variables <- map fromFoldableWithIndex <$>
    ((obj .:? "variables") :: Either JsonDecodeError (Maybe (FO.Object Json)))
  operationName <- obj .:? "operationName"
  pure $ { query, variables, operationName }

responseHeaders :: HTTPure.Headers
responseHeaders = HTTPure.header "Content-Type" "application/json"

createRouter :: DBConnection -> HTTPure.Request -> HTTPure.ResponseM
createRouter connection { body, method: HTTPure.Post, path: [ "graphql" ], headers } =
  case jsonParser body >>= (lmap printJsonDecodeError <<< decodeParams) of
    Left error -> HTTPure.badRequest error
    Right { query, variables, operationName } -> do
      let authHeader = headers !! "Authorization" <|> headers !! "authorization"
      let vars = fromMaybe empty variables
      let execution = graphql schema query vars operationName unit
      _ <- case authHeader of
        Just ah | startsWith "Bearer " ah -> pure unit
        _ -> throwError $ error "authorization header value must start with \"Bearer\""
      userId <- liftEffect $ traverse Auth.validateToken (drop 7 <$> authHeader)
      result <- evalStateT execution { connection, userId }
      HTTPure.ok' responseHeaders $ stringify result
createRouter _ _ = HTTPure.notFound

loggingMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) -> HTTPure.Request -> HTTPure.ResponseM
loggingMiddleware router request = do
  Console.log $ "-> " <> show request.method <> " " <> showPath request.path
  response <- router request
  Console.log $ "<- " <> show response.status
  pure response
    where
      showPath :: Array String -> String
      showPath x
        | Just { head, tail } <- uncons x = showPath tail <> "/" <> head
        | otherwise = ""


corsMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) -> HTTPure.Request -> HTTPure.ResponseM
corsMiddleware router request = fromMaybe (router request) do
  origin <- request.headers !! "Origin"
  if request.method == HTTPure.Options
  then do
    -- Preflight requests
    _ <- request.headers !! "Access-Control-Request-Method"
    requestedHeaders <- request.headers !! "Access-Control-Request-Headers"
    pure $ HTTPure.noContent' (
      HTTPure.headers
        [ "Access-Control-Allow-Origin" /\ origin
        , "Access-Control-Allow-Credentials" /\ "true"
        , "Access-Control-Allow-Methods" /\ "GET,POST"
        , "Access-Control-Allow-Headers" /\ requestedHeaders
        ]
    )
  else
    let
      headers = HTTPure.headers
        [ "Access-Control-Allow-Origin" /\ origin
        , "Access-Control-Allow-Credentials" /\ "true"
        , "Access-Control-Allow-Methods" /\ "GET,POST"
        ]
    in
      pure $ router request <#> \response ->
        response { headers = response.headers <> headers }


main :: Effect Unit
main = catchError server (show >>> Console.log)
  where
    server = launchAff_ do
      _ <- Dotenv.loadFile
      dbUri <- liftEffect $
        lookupEnv "DATABASE_URI" >>= noteME "Environment variable DATABASE_URI not found!"
      conn <- newDB dbUri
      let router = loggingMiddleware $ corsMiddleware $ createRouter conn
      liftEffect $ HTTPure.serve 8080 router $ Console.log "Running server..."
