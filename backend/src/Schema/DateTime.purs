-- This module is an example for how we can easily create a custom scalar type by implementing
-- the functions parseLiteral, parseValue and serialise to turn DateTime values into strings and
-- vice versa. Doing so is quite easy thanks to the purescript-formatters library that contains
-- already all the functionality we need. Internally within our API we can now deal with purescript
-- native DateTime values and don't have to worry about the representation on the API level.
module Schema.DateTime (dateTimeType) where

import Prelude

import Data.Argonaut.Core as Json
import Data.DateTime (DateTime)
import Data.Either (Either(..), fromRight)
import Data.Formatter.DateTime (Formatter, format, parseFormatString, unformat)
import Data.Maybe (Maybe(..))
import GraphQL.Language.AST as AST
import GraphQL.Type (ScalarType(..))
import Partial.Unsafe (unsafePartial)

-- | A scalar type for DateTime values
-- |
-- | The JSON representation of the date is a string in ISO 8601 format. This scalar does pretty
-- | much the same as https://github.com/excitement-engineer/graphql-iso-date for GraphQL.js
dateTimeType :: ScalarType DateTime
dateTimeType = ScalarType { name, description, parseLiteral, parseValue, serialize }
  where
    name = "DateTime"
    description = Just "A date time represented as string in ISO 8601 format."
    parseLiteral (AST.StringValueNode { value }) = parseDateTime value
    parseLiteral _ = Left "Expected string literal node for input type date time."
    parseValue = Json.caseJsonString (Left "Dates must be supplied as ISO strings.") parseDateTime
    serialize = formatDateTime >>> Json.fromString

parseDateTime :: String -> Either String DateTime
parseDateTime = unformat dateFormat

formatDateTime :: DateTime -> String
formatDateTime = format dateFormat

dateFormat ∷ Formatter
dateFormat = parseFormatString "YYYY-MM-DDTHH:mm:ss.SSSZ" # unsafePartial fromRight
