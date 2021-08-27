module Example where

import Prelude

import Api (fetchTodos)
import Data.Maybe (Maybe(..))
import React.Basic.DOM as R
import React.Basic.Hooks (Component, component)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)

mkExample :: Component {}
mkExample = do
  component "Example" \_ -> React.do
    todosResult <- useAff unit fetchTodos

    let todoElements = case todosResult >>= _.viewer of
          Nothing -> [R.div_ [ R.text "Loading Todos..." ]]
          Just viewer -> viewer.todos <#> \todo ->
            R.div_ [ R.text todo.title ]

    pure $
      R.div_
        [ R.h1_ [ R.text "Todos" ]
        , R.div_ todoElements
        ]
