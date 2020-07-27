module Context where

import Control.Monad.State (StateT, get)
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import SQLite3 (DBConnection)

type ContextState =
  { connection :: DBConnection
  , userId :: Maybe Int
  }

type Context = StateT ContextState Aff

getContext :: Context ContextState
getContext = get
