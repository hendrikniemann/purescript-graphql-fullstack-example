module Schema.Error where

import Context (Context)
import Data.Symbol (SProxy(..))
import Data.Variant (Variant, inj)
import GraphQL ((.>), (:>), (!#>))
import GraphQL as GQL

type ValidationErrorRecord = { message :: String, field :: String }

type DataInconsistencyErrorRecord = { message :: String }

data UserError
  = ValidationError { message :: String, field :: String }
  | DataInconsistencyError { message :: String }

validationErrorType :: GQL.ObjectType Context ValidationErrorRecord
validationErrorType = GQL.objectType "ValidationError"
  .> "This error is raised if a validation failed."
  :> GQL.field "message" GQL.string
    .> "The error message that can be displayed in the frontend"
    !#> _.message
  :> GQL.field "field" GQL.string
    .> "The field that failed to validate"
    !#> _.field

dataInconsistencyErrorType :: GQL.ObjectType Context DataInconsistencyErrorRecord
dataInconsistencyErrorType = GQL.objectType "DataInconsistencyError"
  .> "This error is raised if an action fails because of changing underlying data."
  :> GQL.field "message" GQL.string
    .> "The error message that can be displayed in the frontend"
    !#> _.message

type UserErrorVariant = Variant
  ( validationError :: ValidationErrorRecord
  , dataInconsistencyError :: DataInconsistencyErrorRecord
  )

injectUserError :: UserError -> UserErrorVariant
injectUserError (ValidationError r) = inj (SProxy :: _ "validationError") r
injectUserError (DataInconsistencyError r) = inj (SProxy :: _ "dataInconsistencyError") r

userErrorType :: GQL.UnionType Context UserErrorVariant
userErrorType =
  GQL.union "UserError"
    { validationError: validationErrorType
    , dataInconsistencyError: dataInconsistencyErrorType
    }
