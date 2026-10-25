#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -X POST $DB/movies_a/_find -H "Content-Type: application/json" -d '{
  "selector": {"genres": {"$elemMatch": {"$eq": "SciFi"}}},
  "fields": ["_id", "title", "genres"],
  "limit": 1000
}'

curl -s -X POST $DB/movies_b/_find -H "Content-Type: application/json" -d '{
  "selector": {"type": "movie", "genres": {"$elemMatch": {"$eq": "SciFi"}}},
  "fields": ["_id", "title", "genres"],
  "limit": 1000
}'
