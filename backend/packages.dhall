let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.8-20210226/packages.dhall sha256:7e973070e323137f27e12af93bc2c2f600d53ce4ae73bb51f34eb7d7ce0a43ea

let overrides = {=}

let additions =
      { graphql =
        { dependencies =
          [ "argonaut"
          , "console"
          , "control"
          , "effect"
          , "enums"
          , "foldable-traversable"
          , "nullable"
          , "numbers"
          , "prelude"
          , "psci-support"
          , "record"
          , "spec"
          , "string-parsers"
          ]
        , repo = "https://github.com/hendrikniemann/purescript-graphql.git"
        , version = "ac07120"
        }
      }

in  upstream // overrides // additions
