#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -X PUT $DB/movies_a/_design/stats -H "Content-Type: application/json" -d @partA/views_a.json
curl -s -X PUT $DB/movies_b/_design/stats -H "Content-Type: application/json" -d @partA/views_b.json

curl -s "$DB/movies_a/_design/stats/_view/movies_per_genre?group=true"
curl -s "$DB/movies_b/_design/stats/_view/movies_per_genre?group=true"
