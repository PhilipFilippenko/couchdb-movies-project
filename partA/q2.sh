#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s $DB/movies_a/3000

curl -s $DB/movies_b/movie_3000

curl -s -X POST $DB/movies_b/_find -H "Content-Type: application/json" -d '{
  "selector": {"type": "cast", "movie_id": "movie_3000"},
  "fields": ["actor_id"]
}'

curl -s -X POST "$DB/movies_b/_all_docs?include_docs=true" -H "Content-Type: application/json" -d '{
  "keys": ["actor_452d3e6437f3", "actor_9e59da77f25c", "actor_c7787b38c78c", "actor_ca5554c9d1af"]
}'
