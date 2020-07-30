# PureScript GraphQL Example

## Getting started

- If needed install [Node.js](nodejs.org)
- If needed install PureScript and Spago (follow [official guide](https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md))
- Clone this repository and switch into root folder
- Create `.env` file and insert environment variables: `DATABASE_URI` and `JWT_SECRET`
- Install NPM dependencies: `npm install`
- Run `npm run dev`, this will run spago with nodemon (since `--watch` seems to be unreliable)
- Run your local GraphQL playground and connect to `http://localhost:8080/graphql`

## Create SQLite tables and initialise a user

Use the following create statements to create two simple tables in the database:

```sql
CREATE TABLE "user" (
	"id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"name"	TEXT NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	"created_at"	TEXT NOT NULL,
	"password_hash"	TEXT NOT NULL
);

CREATE TABLE "todo" (
	"id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"title"	TEXT NOT NULL,
	"created_at"	TEXT NOT NULL,
	"completed_at"	TEXT,
	"user_id"	INTEGER,
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
```

Then insert one row into the user table.

```sql
INSERT INTO "user" ("name", "email", "created_at", "password_hash")
VALUES ('test user', 'test@example.com', datetime(), '0000000000000000');
```

This should create a user with ID `1`. Use [jwt.io](https://jwt.io) to create a new token for this user using the secret you chose in the beginning. Use the following payload:

```json
{
  "sub": "1",
  "iat": 1500000000,
  "nbf": 1500000000,
  "exp": 1900000000
}
```

In the future there will be queries and mutation for the user creation and login.

## Interesting Modules

### `Main`

`Main` defines a HTTPure server that accepts requests to the `/graphql` endpoint.
It then prepares the execution context with data from the request and executes the query towards the schema.

### `Schema.Todo`

`Schema.Todo` defines a plain GraphQL object type and serves as a basic example of how to build object types in PureScript GraphQL. It also contains an input object type that serves as a template for new todos.

### `Schema.DateTime`

`Schema.DateTime` contains a custom date scalar in little more than ten lines of code.
PureScript's small but powerful ecosystem allows us to build new scalars very elegantly.

### `DB`

`DB` contains functions that talk to the database.
These functions are mostly used by top level mutation and query fields.

### `Schema.Query` and `Schema.Mutation`

`Schema.Query` and `Schema.Mutation` bring everything from above together and contain the root query and mutation fields.
