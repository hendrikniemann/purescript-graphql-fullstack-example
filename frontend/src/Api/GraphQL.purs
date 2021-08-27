module Api.GraphQL (graphql, graphql') where

import Prelude

import Affjax as AX
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, JsonDecodeError, decodeJson, encodeJson, (.:), (.:?), printJsonDecodeError)
import Data.Either (Either(..), either)
import Data.HTTP.Method as Method
import Data.Maybe (Maybe, fromMaybe)
import Effect.Aff (Aff, throwError, error)

type GraphQLLocation = { line :: Int, column :: Int }

type GraphQLError = { message :: String, {-- location :: Array GraphQLLocation, --} path :: Array String }

type GraphQLResponse a = { data :: Maybe a, errors :: Maybe (Array GraphQLError) }

graphql :: forall vars res. EncodeJson vars => DecodeJson res => String -> vars -> Aff res
graphql query variables = makeRequest (encodeJson { query, variables })

graphql' :: forall res. DecodeJson res => String -> Aff res
graphql' query = makeRequest (encodeJson { query })

makeRequest :: forall res. DecodeJson res => Json -> Aff res
makeRequest bodyArgs = do
  let content = pure $ RequestBody.json bodyArgs
  response <- either throwAffjaxError pure =<< AX.request
    ( AX.defaultRequest
        { url = "http://localhost:8080/graphql"
        , method = Left Method.POST
        , content = content
        , responseFormat = ResponseFormat.json
        , headers = [ RequestHeader "Authorization" token ]
        }
    )
  case (decodeGraphQLResponse response.body :: Either JsonDecodeError (GraphQLResponse res)) of
    Left err -> throwError $ error $ printJsonDecodeError err
    Right res -> fromMaybe (throwError $ error "A GraphQL Error occurred") $ map pure res.data

throwAffjaxError :: forall a. AX.Error -> Aff a
throwAffjaxError err = throwError $ error $
  "Error fetching data from GraphQL endpoint:\n" <> AX.printError err

decodeGraphQLResponse :: forall a. DecodeJson a => Json -> Either JsonDecodeError (GraphQLResponse a)
decodeGraphQLResponse json = do
  obj <- decodeJson json
  d <- (obj .: "data")
  e <- (obj .:? "errors")
  pure { data: d, errors: e }

token :: String
token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyIiwiaWF0IjoxNTE2MjM5MDIyLCJuYmYiOjE1MTYyMzkwMjIsImV4cCI6MTkwMDAwMDAwMH0.1YBTmm2MzUb2utRMklQFHqYU7r6NshmVJbZnnWzkc60"
