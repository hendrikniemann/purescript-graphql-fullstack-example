module State where

import Prelude

data Filter = ShowAll | ShowUncompleted

instance Eq Filter where
  eq ShowAll ShowAll = true
  eq ShowUncompleted ShowUncompleted = true
  eq _ _ = false

instance Show Filter where
  show ShowAll = "show all"
  show ShowUncompleted = "show only uncompleted"

type State =
  { filter :: Filter }

data Action
  = SetFilter { filter :: Filter }

defaultState :: State
defaultState =
  { filter: ShowAll }

reducer :: State -> Action -> State
reducer state action = case action of
  SetFilter { filter } -> state { filter = filter }
