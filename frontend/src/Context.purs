module Context where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class.Console as Console
import React.Basic (JSX, ReactContext, createContext)
import React.Basic.Hooks as React
import State (Action, State, defaultState, reducer)

type StateContext = (ReactContext { state :: State, dispatch :: Action -> Effect Unit })

createStateContext :: Effect StateContext
createStateContext = createContext { state: defaultState, dispatch: const (Console.log "Default resolver called") }

mkContextProvider :: StateContext -> React.Component { children :: Array JSX }
mkContextProvider stateContext = do
  r <- React.mkReducer reducer

  React.component "ContextProvider" \{ children } -> React.do
    state /\ dispatch <- React.useReducer defaultState r

    value <- React.useMemo state \_ -> { state, dispatch }

    pure $
      React.provider stateContext value children
