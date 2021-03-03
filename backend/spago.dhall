{ name = "graphql-example"
, dependencies =
  [ "argonaut-codecs"
  , "argonaut-core"
  , "console"
  , "datetime"
  , "debug"
  , "dotenv"
  , "effect"
  , "foreign-object"
  , "formatters"
  , "graphql"
  , "httpure"
  , "node-process"
  , "node-sqlite3"
  , "prelude"
  , "psci-support"
  , "refs"
  , "simple-jwt"
  , "spec"
  , "stringutils"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
