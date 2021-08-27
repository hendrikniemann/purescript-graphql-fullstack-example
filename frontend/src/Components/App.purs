module Components.App where

import Prelude

import Components.TodoList as TodoList
import Context (createStateContext, mkContextProvider)
import React.Basic.Hooks as React
import ReactQuery (queryClientProvider)
import ReactQuery.QueryClient (createQueryClient)

mkApp :: React.Component {}
mkApp = do
  stateContext <- createStateContext
  todoList <- TodoList.mkTodoList stateContext
  contextProvider <- mkContextProvider stateContext
  queryClient <- createQueryClient {}

  React.component "App" \_ -> React.do
    pure $
      React.element
        queryClientProvider
        { children: [ contextProvider { children: [ todoList {} ] } ]
        , client: queryClient
        }
