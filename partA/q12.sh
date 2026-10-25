#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s "$DB/movies_a/_design/stats/_view/movies_per_actor?group=true&limit=20"
curl -s "$DB/movies_b/_design/stats/_view/movies_per_actor?group=true&limit=20"

curl -s "$DB/movies_a/_design/stats/_view/movies_per_actor?group=true&key=%22Robert%20De%20Niro%22"
curl -s -X POST $DB/movies_b/_find -H "Content-Type: application/json" -d '{"selector": {"type": "actor", "name": "Robert De Niro"}}'
