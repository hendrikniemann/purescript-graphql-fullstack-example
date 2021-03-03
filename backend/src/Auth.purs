module Auth (signToken, validateToken) where

import Prelude

import Data.DateTime.Instant (unInstant)
import Data.Either (Either(..))
import Data.Int as Int
import Data.Newtype (unwrap)
import Debug.Trace (spy)
import Effect (Effect)
import Effect.Exception (Error, error, throwException)
import Effect.Now (now)
import Node.Process (lookupEnv)
import Node.Simple.Jwt as Jwt
import Util (noteME)

type AuthPayload =
  { sub :: String
  , nbf :: Int
  , exp :: Int
  , iat :: Int
  }

-- | Create a new token with the provided user id as subject, that is valid for 24 hours
signToken :: Int -> Effect String
signToken id = do
  timestamp <- currentTimestamp
  let payload = { sub: show id, iat: timestamp, nbf: timestamp, exp: timestamp + 60 * 60 * 24 }
  secret <- getSecret
  Jwt.toString <$> Jwt.encode secret Jwt.HS256 payload

-- | Validate a JWT token and return the user id encoded in the subject field
validateToken :: String -> Effect Int
validateToken token = do
  secret <- getSecret
  time <- currentTimestamp
  result <- (Jwt.decode ( spy "secret" secret) (spy "jwt" $ Jwt.fromString token) :: Effect (Either Jwt.JwtError AuthPayload))
  case result of
    Left err -> throwException $ toError err
    Right { sub, nbf, exp } ->
      if nbf < time && exp > time
      then noteME "Invalid subject field in JWT token." $ Int.fromString sub
      else throwException $ error "Token expired or not valid yet."

getSecret :: Effect String
getSecret = noteME "Missing environment variable JWT_SECRET!" =<< lookupEnv "JWT_SECRET"

currentTimestamp :: Effect Int
currentTimestamp = Int.round <$> (_ / 1000.0) <$> unwrap <$> unInstant <$> now

toError :: Jwt.JwtError -> Error
toError e = error $ "Some error happened in JWT encoding/decoding: " <> (show e)
