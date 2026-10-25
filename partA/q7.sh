#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -X POST $DB/movies_a/_find -H "Content-Type: application/json" -d '{
  "selector": {"actors": {"$all": ["Leonard Nimoy", "James Doohan"]}},
  "fields": ["_id", "title", "actors"]
}'
