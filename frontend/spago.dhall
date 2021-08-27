{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "affjax"
  , "argonaut"
  , "arrays"
  , "console"
  , "debug"
  , "effect"
  , "either"
  , "exceptions"
  , "graphql-fundeps"
  , "http-methods"
  , "js-date"
  , "maybe"
  , "nullable"
  , "prelude"
  , "psci-support"
  , "react-basic"
  , "react-basic-dom"
  , "react-basic-hooks"
  , "simple-json"
  , "tuples"
  , "unsafe-coerce"
  , "web-dom"
  , "web-html"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
