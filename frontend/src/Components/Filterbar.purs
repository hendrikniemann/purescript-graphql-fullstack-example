module Components.Filterbar where

import Prelude

import Context (StateContext)
import Data.Maybe (Maybe(..))
import Effect.Class.Console as Console
import React.Basic.DOM as R
import React.Basic.DOM.Events (targetChecked)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, useContext)
import React.Basic.Hooks as React
import State (Action(..), Filter(..))

mkFilterbar :: StateContext -> Component {}
mkFilterbar stateContext = do
  component "Filterbar" \_ -> React.do
    { state, dispatch } <- useContext stateContext

    let
      onChange = case _ of
        Just true -> do
          Console.log $ show state.filter
          dispatch (SetFilter { filter: ShowAll })
        Just false -> dispatch (SetFilter { filter: ShowUncompleted })
        Nothing -> pure unit

    React.useEffect state.filter do
      Console.logShow state.filter
      pure $ pure unit

    pure $
      R.div
        { className: "p-2 bg-gray-200"
        , children:
            [ R.input
                { type: "checkbox"
                , name: "show-all"
                , className: "mr-2"
                , checked: state.filter == ShowAll
                , onChange: handler targetChecked onChange
                }
            , R.label { htmlFor: "show-all", children: [ R.text "Show all" ] }
            ]
        }