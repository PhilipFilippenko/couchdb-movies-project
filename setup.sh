#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -X PUT $DB/movies_a
curl -s -X PUT $DB/movies_b

npx couchimport --url $DB --db movies_a data/schema_a.jsonl
npx couchimport --url $DB --db movies_b data/schema_b.jsonl

curl -s -X POST $DB/movies_b/_index -H "Content-Type: application/json" -d '{"index": {"fields": ["type", "movie_id"]}, "name": "cast-by-movie"}'
curl -s -X POST $DB/movies_b/_index -H "Content-Type: application/json" -d '{"index": {"fields": ["type", "actor_id"]}, "name": "cast-by-actor"}'
curl -s -X POST $DB/movies_b/_index -H "Content-Type: application/json" -d '{"index": {"fields": ["type", "name"]}, "name": "actor-by-name"}'
curl -s -X POST $DB/movies_b/_index -H "Content-Type: application/json" -d '{"index": {"fields": ["type"]}, "name": "by-type"}'

curl -s -X PUT $DB/_node/_local/_config/chttpd/enable_cors -d '"true"'
curl -s -X PUT $DB/_node/_local/_config/cors/origins -d '"http://localhost:8080"'
curl -s -X PUT $DB/_node/_local/_config/cors/credentials -d '"true"'
curl -s -X PUT $DB/_node/_local/_config/cors/methods -d '"GET, PUT, POST, HEAD, DELETE"'
curl -s -X PUT $DB/_node/_local/_config/cors/headers -d '"accept, authorization, content-type, origin, referer"'
