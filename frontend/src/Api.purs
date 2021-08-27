module Api where

import Prelude

import Api.GraphQL (graphql, graphql')
import Data.Maybe (Maybe)
import Effect.Aff (Aff)

type Todo =
  { id :: String
  , title :: String
  , createdAt :: String
  , isCompleted :: Boolean
  }

fetchTodos :: Aff { viewer :: Maybe { todos :: Array Todo } }
fetchTodos = graphql' """
    query GetViewerTodos {
      viewer {
        todos {
          id
          title
          createdAt
          isCompleted
        }
      }
    }
  """

fetchTodo :: String -> Aff { todo :: Maybe Todo }
fetchTodo id = graphql """
  query GetTodoById($id: ID!) {
    todo(id: $id) {
      id
      title
    }
  }
  """ { id }

completeTodo :: String -> Aff { completeTodo :: { success :: Boolean, todo :: Maybe Todo } }
completeTodo id = graphql """mutation CompleteTodo($id: ID!) {
    completeTodo(id: $id) {
      success
      todo {
        id
        title
        createdAt
        isCompleted
      }
    }
  }
  """ { id }

uncompleteTodo :: String -> Aff { uncompleteTodo :: { success :: Boolean, todo :: Maybe Todo } }
uncompleteTodo id = graphql """mutation UncompleteTodo($id: ID!) {
    uncompleteTodo(id: $id) {
      success
      todo {
        id
        title
        createdAt
        isCompleted
      }
    }
  }
  """ { id }

setTodoCompletion :: { id :: String, value :: Boolean } -> Aff { success :: Boolean, todo :: Maybe Todo }
setTodoCompletion { id, value } =
  if value then _.completeTodo <$> completeTodo id
  else _.uncompleteTodo <$> uncompleteTodo id
