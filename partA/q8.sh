#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -X POST $DB/movies_a/_find -H "Content-Type: application/json" -d '{"selector": {"year": {"$exists": true}}}'
curl -s -X POST $DB/movies_b/_find -H "Content-Type: application/json" -d '{"selector": {"type": "movie", "year": {"$exists": true}}}'

node partA/q8.mjs

curl -s -X POST $DB/movies_a/_index -H "Content-Type: application/json" -d '{"index": {"fields": ["year"]}, "name": "by-year"}'
curl -s -X POST $DB/movies_a/_find -H "Content-Type: application/json" -d '{
  "selector": {"year": {"$gte": 1990, "$lte": 2000}, "genres": {"$elemMatch": {"$eq": "Eastern"}}},
  "fields": ["_id", "title", "year", "genres"]
}'

curl -s -X POST $DB/movies_b/_index -H "Content-Type: application/json" -d '{"index": {"fields": ["type", "year"]}, "name": "movie-by-year"}'
curl -s -X POST $DB/movies_b/_find -H "Content-Type: application/json" -d '{
  "selector": {"type": "movie", "year": {"$gte": 1990, "$lte": 2000}, "genres": {"$elemMatch": {"$eq": "Eastern"}}},
  "fields": ["_id", "title", "year", "genres"]
}'
