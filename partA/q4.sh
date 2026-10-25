#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
rev() { curl -s $DB/$1 | grep -o '"_rev":"[^"]*"' | cut -d'"' -f4; }
set -x

REV=$(rev movies_a/3000)
curl -s -X DELETE "$DB/movies_a/3000?rev=$REV"

curl -s -X POST $DB/movies_b/_find -H "Content-Type: application/json" -d '{
  "selector": {"type": "cast", "movie_id": "movie_3000"},
  "fields": ["_id"]
}'

for ID in movie_3000 cast_3000_452d3e6437f3 cast_3000_9e59da77f25c cast_3000_c7787b38c78c cast_3000_86c23b6157fa; do
  REV=$(rev movies_b/$ID)
  curl -s -X DELETE "$DB/movies_b/$ID?rev=$REV"
done

curl -s $DB/movies_a/3000
curl -s $DB/movies_b/movie_3000
