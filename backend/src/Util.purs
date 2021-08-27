module Util where

import Prelude

import Context (Context, getContext)
import Control.Monad.Error.Class (class MonadError, throwError)
import Data.DateTime (DateTime)
import Data.JSDate (now, toDateTime)
import Data.Maybe (Maybe(..), fromJust)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Class (liftAff)
import Effect.Exception (Error, error)
import Partial.Unsafe (unsafePartial)
import SQLite3 (DBConnection)

noteME :: forall m a. MonadError Error m => String -> Maybe a -> m a
noteME _ (Just a) = pure a
noteME m Nothing = throwError $ error m

currentDateTime :: Effect DateTime
currentDateTime = unsafePartial fromJust <$> toDateTime <$> now

liftDbFunction :: forall a. (DBConnection -> Aff a) -> Context a
liftDbFunction fn = getContext >>= _.connection >>> fn >>> liftAff

getUserIdOrThrow :: Context Int
getUserIdOrThrow = do
  { userId } <- getContext
  noteME "Unauthenticated: This field requires a valid authentication token." userId
