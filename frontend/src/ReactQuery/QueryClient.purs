module ReactQuery.QueryClient
  ( QueryClient
  , createQueryClient
  , QueryClientOptions
  , invalidateQueries
  , invalidateQueries'
  , InvalidateQueriesOptions
  ) where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn3, runEffectFn3)
import Prim.Row (class Union)

data QueryClient

foreign import createQueryClient :: QueryClientOptions -> Effect QueryClient

type QueryClientOptions = {}

type InvalidateQueriesOptions =
  ( exact :: Boolean
  , refetchActive :: Boolean
  , refetchInactive :: Boolean
  )

foreign import invalidateQueries_ :: forall options. EffectFn3 QueryClient (Array String) options Unit

invalidateQueries
  :: forall options options_
   . Union options options_ InvalidateQueriesOptions
  => QueryClient
  -> Array String
  -> { | options }
  -> Effect Unit
invalidateQueries = runEffectFn3 invalidateQueries_

invalidateQueries'
  :: QueryClient
  -> Array String
  -> Effect Unit
invalidateQueries' queryClient queryPath = runEffectFn3 invalidateQueries_ queryClient queryPath {}
