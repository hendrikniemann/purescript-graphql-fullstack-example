# PureScript GraphQL Example

## Getting started

- If needed install [Node.js](nodejs.org)
- If needed install PureScript and Spago (follow [official guide](https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md))
- Clone this repository and switch into root folder
- Create `.env` file and insert environment variables: `DATABASE_URI` and `JWT_SECRET`
- Install NPM dependencies: `npm install`
- Run `npm run dev`, this will run spago with nodemon (since `--watch` seems to be unreliable)
- Run your local GraphQL playground and connect to `http://localhost:8080/graphql`

## Interesting Modules

### `Main`

`Main` defines a HTTPure server that accepts requests to the `/graphql` endpoint.
It then prepares the execution context with data from the request and executes the query towards the schema.

### `Schema.Todo`

`Schema.Todo` defines a plain GraphQL object type and serves as a basic example of how to build object types in PureScript GraphQL.

### `Schema.DateTime`

`Schema.DateTime` contains a custom date scalar in little more than ten lines of code.
PureScript's small but powerful ecosystem allows us to build new scalars very elegantly.

### `DB`

`DB` contains functions that talk to the database.
These functions are mostly used by top level mutation and query fields.
