let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200423/packages.dhall sha256:c180a06bb5444fd950f8cbdd6605c644fd246deb397e62572b8f4a6b9dbcaf22

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

in  upstream ⫽ overrides ⫽ additions
