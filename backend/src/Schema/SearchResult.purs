module Schema.SearchResult where

import Context (Context)
import DB (User, Todo)
import Data.Variant (Variant)
import GraphQL as GQL
import Schema.Todo (todoType)
import Schema.User (userType)

searchResultType :: GQL.UnionType Context (Variant (user :: User, todo :: Todo))
searchResultType = GQL.union "SearchResult" { user: userType, todo: todoType }
