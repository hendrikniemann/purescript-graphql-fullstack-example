module Components.Todo where

import Prelude

import Api (Todo, setTodoCompletion)
import Data.Maybe (Maybe(..))
import Effect.Aff (launchAff_)
import Effect.Console as Console
import React.Basic.DOM as R
import React.Basic.DOM.Events (targetChecked)
import React.Basic.Events (handler)
import React.Basic.Hooks as React
import ReactQuery.Hooks (useMutation, useQueryClient)
import ReactQuery.QueryClient (invalidateQueries')

mkTodo :: React.Component { todo :: Todo }
mkTodo = do
  React.component "Todo" \props -> React.do
    queryClient <- useQueryClient
    { mutate } <- useMutation setTodoCompletion
      { onSuccess: invalidateQueries' queryClient [ "todos" ] }

    let
      onChange = handler targetChecked $ case _ of
        Just value -> launchAff_ (mutate { id: props.todo.id, value })
        Nothing -> Console.warn "No event target found in handler"

    pure $ R.div
      { className: "p-2 flex gap-x-1"
      , children:
          [ R.input { type: "checkbox", onChange, checked: props.todo.isCompleted }
          , R.h2_ [ R.text props.todo.title ]
          ]
      }
