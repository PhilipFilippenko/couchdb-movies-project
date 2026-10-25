#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -X PUT $DB/movies_a/3000 -H "Content-Type: application/json" -d '{
  "title": "Blade Runner 2049",
  "actors": ["Ryan Gosling", "Harrison Ford", "Ana de Armas", "Jared Leto"],
  "genres": ["SciFi", "Thriller"]
}'

curl -s -X POST $DB/movies_b/_all_docs -H "Content-Type: application/json" -d '{
  "keys": ["actor_452d3e6437f3", "actor_9e59da77f25c", "actor_c7787b38c78c", "actor_ca5554c9d1af"]
}'

curl -s -X POST $DB/movies_b/_bulk_docs -H "Content-Type: application/json" -d '{"docs": [
  {"_id": "movie_3000", "type": "movie", "title": "Blade Runner 2049", "genres": ["SciFi", "Thriller"]},
  {"_id": "actor_c7787b38c78c", "type": "actor", "name": "Ana de Armas"},
  {"_id": "cast_3000_452d3e6437f3", "type": "cast", "movie_id": "movie_3000", "actor_id": "actor_452d3e6437f3"},
  {"_id": "cast_3000_9e59da77f25c", "type": "cast", "movie_id": "movie_3000", "actor_id": "actor_9e59da77f25c"},
  {"_id": "cast_3000_c7787b38c78c", "type": "cast", "movie_id": "movie_3000", "actor_id": "actor_c7787b38c78c"},
  {"_id": "cast_3000_ca5554c9d1af", "type": "cast", "movie_id": "movie_3000", "actor_id": "actor_ca5554c9d1af"}
]}'
