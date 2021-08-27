module Components.TodoList where

import Prelude

import Api (Todo, fetchTodos)
import Components.Filterbar as Filterbar
import Components.Todo (mkTodo)
import Context (StateContext)
import Data.Array as Array
import Data.Maybe (fromMaybe)
import React.Basic.DOM as R
import React.Basic.Hooks as React
import ReactQuery.Hooks (UseQueryResult(..), useQuery')
import State (Filter(..))

mkTodoList :: StateContext -> React.Component {}
mkTodoList stateContext = do
  filterbar <- Filterbar.mkFilterbar stateContext
  todo <- mkTodo

  React.component "TodoList" \_ -> React.do
    { state } <- React.useContext stateContext

    todoQuery <- useQuery' [ "todos" ] (const fetchTodos)

    let
      todosJSX = case todoQuery of
        QuerySuccess result ->
          let
            todos = fromMaybe [] $ result.data.viewer <#> _.todos
          in
            R.div
              { className: "w-full flex flex-col gap-2 flex-grow"
              , children: Array.filter (todoFilter state.filter) todos <#> { todo: _ } <#> todo
              }
        QueryError _ ->
          R.div { className: "", children: [ R.text "There was an error fetching todos..." ] }
        _ ->
          R.div { className: "", children: [ R.text "Loading todos..." ] }

    pure $
      R.div
        { className: "container mx-auto flex flex-col h-"
        , style: R.css { height: "100vh" }
        , children:
            [ R.div
                { className: "bg-blue-500 p-2 color-white"
                , children: [ R.h1_ [ R.text "My Todo App" ] ]
                }
            , todosJSX
            , filterbar {}
            ]
        }

todoFilter :: Filter -> Todo -> Boolean
todoFilter ShowAll _ = true
todoFilter ShowUncompleted todo = not todo.isCompleted
