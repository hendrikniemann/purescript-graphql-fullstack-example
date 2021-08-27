module ReactQuery.Hooks where

import Prelude

import Control.Promise (Promise, fromAff, toAffE)
import Data.JSDate (JSDate)
import Data.Nullable (Nullable)
import Effect (Effect)
import Effect.Aff (Aff, Error)
import Effect.Uncurried (EffectFn1, EffectFn2, mkEffectFn1, runEffectFn1, runEffectFn2)
import Effect.Unsafe (unsafePerformEffect)
import Prim.Row (class Union)
import React.Basic.Hooks (unsafeHook)
import React.Basic.Hooks.Internal (Hook)
import ReactQuery.QueryClient (QueryClient)
import Unsafe.Coerce (unsafeCoerce)

type NativeUseQueryResult d =
  { data :: Nullable d
  , dataUpdatedAt :: JSDate
  , error :: Nullable Error
  , errorUpdatedAt :: JSDate
  , isError :: Boolean
  , isFetched :: Boolean
  , isFetchedAfterMount :: Boolean
  , isFetching :: Boolean
  , isIdle :: Boolean
  , isLoading :: Boolean
  , isLoadingError :: Boolean
  , isPlaceholderData :: Boolean
  , isPreviousData :: Boolean
  , isRefetchError :: Boolean
  , isStale :: Boolean
  , isSuccess :: Boolean
  , refetch :: Effect Unit
  , remove :: Effect Unit
  , status :: String
  , failureCount :: Int
  }

data UseQueryResult d
  = QueryIdle
  | QueryLoading
  | QueryError { error :: Error, errorUpdatedAt :: JSDate, failureCount :: Int }
  | QuerySuccess
      { data :: d
      , dataUpdatedAt :: JSDate
      , isFetchedAfterMount :: Boolean
      , isFetching :: Boolean
      , isPlaceholderData :: Boolean
      , isPreviousData :: Boolean
      , isRefetchError :: Boolean
      , isStale :: Boolean
      , isSuccess :: Boolean
      , refetch :: Effect Unit
      , remove :: Effect Unit
      }

foreign import data UseQuery :: Type -> Type -> Type

type QueryFunction d = Array String -> Aff d

foreign import useQuery_
  :: forall d. EffectFn2 (Array String) ((Array String) -> Promise d) (NativeUseQueryResult d)

-- type QueryOptions =
--   { cacheTime :: Int
--   , enabled :: Boolean
--   , initialData
--   , initialDataUpdatedAt
--   , isDataEqual
--   , keepPreviousData
--   , notifyOnChangeProps
--   , notifyOnChangePropsExclusions
--   , onError
--   , onSettled
--   , onSuccess
--   , queryKeyHashFn
--   , refetchInterval
--   , refetchIntervalInBackground
--   , refetchOnMount
--   , refetchOnReconnect
--   , refetchOnWindowFocus
--   , retry
--   , retryOnMount
--   , retryDelay
--   , select
--   , staleTime
--   , structuralSharing
--   , suspense
--   , useErrorBoundary
--   }

useQuery'
  :: forall d
   . Array String
  -> QueryFunction d
  -> Hook (UseQuery d) (UseQueryResult d)
useQuery' queryKey queryFunction =
  unsafeHook do
    result <-
      runEffectFn2
        useQuery_
        queryKey
        \keys -> unsafePerformEffect (fromAff $ queryFunction keys)
    pure $
      if result.isIdle then QueryIdle
      else if result.isLoading then QueryLoading
      else if result.isError then QueryError { error: unsafeCoerce result.error, errorUpdatedAt: result.errorUpdatedAt, failureCount: result.failureCount }
      else QuerySuccess
        { data: unsafeCoerce result.data
        , dataUpdatedAt: result.dataUpdatedAt
        , isFetchedAfterMount: result.isFetchedAfterMount
        , isFetching: result.isFetching
        , isPlaceholderData: result.isPlaceholderData
        , isPreviousData: result.isPreviousData
        , isRefetchError: result.isRefetchError
        , isStale: result.isStale
        , isSuccess: result.isSuccess
        , refetch: result.refetch
        , remove: result.remove
        }

foreign import data UseMutation :: Type -> Type -> Type

type UseMutationOptions =
  ( mutationKey :: String
  , onError :: Effect Unit
  , onMutate :: Effect Unit
  , onSettled :: Effect Unit
  , onSuccess :: Effect Unit
  )

type NativeUseMutationResult v d =
  { data :: Nullable d
  , error :: Nullable Error
  , mutate :: EffectFn1 v Unit
  , mutateAsync :: EffectFn1 v (Promise d)
  , isError :: Boolean
  , isIdle :: Boolean
  , isLoading :: Boolean
  , isSuccess :: Boolean
  , reset :: Effect Unit
  , status :: String
  }

data MutationResult d
  = MutationIdle
  | MutationLoading
  | MutationError Error
  | MutationSuccess d

type UseMutationResult v d = { mutate :: v -> Aff d, reset :: Effect Unit, result :: MutationResult d }

foreign import useMutation_
  :: forall options v d. EffectFn2 (EffectFn1 v (Promise d)) options (NativeUseMutationResult v d)

useMutation
  :: forall options options_ v d
   . Union options options_ UseMutationOptions
  => (v -> Aff d)
  -> { | options }
  -> Hook (UseMutation d) (UseMutationResult v d)
useMutation mutationFunction options =
  unsafeHook do
    result <-
      runEffectFn2
        useMutation_
        (mkEffectFn1 (mutationFunction >>> fromAff))
        options
    pure
      { mutate: \vars -> runEffectFn1 result.mutateAsync vars # toAffE
      , reset: result.reset
      , result:
          if result.isIdle then MutationIdle
          else if result.isLoading then MutationLoading
          else if result.isError then MutationError (unsafeCoerce result.error)
          else MutationSuccess (unsafeCoerce result.data)
      }

data UseQueryClient :: Type -> Type
data UseQueryClient a

foreign import useQueryClient_ :: Effect QueryClient

useQueryClient :: Hook UseQueryClient QueryClient
useQueryClient = unsafeHook useQueryClient_
