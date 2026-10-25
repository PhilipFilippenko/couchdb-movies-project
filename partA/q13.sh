#!/usr/bin/env bash
DB=http://admin:123456@127.0.0.1:5984
set -x

curl -s -G "$DB/movies_a/_design/stats/_view/actor_genre" \
  --data-urlencode 'group_level=2' \
  --data-urlencode 'startkey=["Robert De Niro"]' \
  --data-urlencode 'endkey=["Robert De Niro",{}]'

curl -s -G "$DB/movies_a/_design/stats/_view/actor_genre" \
  --data-urlencode 'group_level=2' \
  --data-urlencode 'limit=30'
