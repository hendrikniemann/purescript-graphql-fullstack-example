module ReactQuery where

import React.Basic as React
import ReactQuery.QueryClient (QueryClient)

type QueryClientProviderProps =
  { children :: Array React.JSX
  , client :: QueryClient
  }

foreign import queryClientProvider :: React.ReactComponent QueryClientProviderProps
