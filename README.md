# CouchDB Movies Project

CouchDB runs locally on http://127.0.0.1:5984 (user admin, password 123456).

- `data` - the movie datasets
- `partA` - queries for Q1-Q13 (one file per question)
- `partB` - PouchDB offline app for Q15

## Setup

```
npm install
bash setup.sh
```

This creates the databases `movies_a` (schema A) and `movies_b` (schema B) and loads the data.

## Part A

Run the files from the project folder, for example:

```
bash partA/q1.sh
bash partA/q11.sh
```

Q1-Q4 use the same movie (id 3000), so run them in order. Run q11 before q12 and q13 (it creates the views).

## Part B

```
node partB/server.js
```

Then open http://localhost:8080.
