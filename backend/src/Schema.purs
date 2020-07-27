module Schema where

import Prelude (Unit)

import Context (Context)
import Data.Maybe (Maybe(..))
import GraphQL.Type as GQL
import Schema.Mutation (mutationType)
import Schema.Query (queryType)

schema :: GQL.Schema Context Unit
schema = GQL.Schema { query: queryType, mutation: Just mutationType }
