#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
rev() { curl -s $DB/$1 | grep -o '"_rev":"[^"]*"' | cut -d'"' -f4; }
set -x

REV=$(rev movies_a/3000)
curl -s -X PUT $DB/movies_a/3000 -H "Content-Type: application/json" -d '{
  "_rev": "'$REV'",
  "title": "Blade Runner 2049",
  "actors": ["Ryan Gosling", "Harrison Ford", "Ana de Armas", "Dave Bautista"],
  "genres": ["SciFi", "Thriller", "Drama"]
}'

REV=$(rev movies_b/movie_3000)
curl -s -X PUT $DB/movies_b/movie_3000 -H "Content-Type: application/json" -d '{
  "_rev": "'$REV'",
  "type": "movie",
  "title": "Blade Runner 2049",
  "genres": ["SciFi", "Thriller", "Drama"]
}'

REV=$(rev movies_b/cast_3000_ca5554c9d1af)
curl -s -X DELETE "$DB/movies_b/cast_3000_ca5554c9d1af?rev=$REV"

curl -s -X POST $DB/movies_b/_bulk_docs -H "Content-Type: application/json" -d '{"docs": [
  {"_id": "actor_86c23b6157fa", "type": "actor", "name": "Dave Bautista"},
  {"_id": "cast_3000_86c23b6157fa", "type": "cast", "movie_id": "movie_3000", "actor_id": "actor_86c23b6157fa"}
]}'

curl -s $DB/movies_a/3000
curl -s $DB/movies_b/movie_3000
