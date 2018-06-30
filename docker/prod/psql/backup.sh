#/bin/bash

PGPASSWORD=$POSTGRES_PASSWORD \
  pg_dump \
  --host=psql \
  --dbname=$POSTGRES_DB \
  --username=$POSTGRES_USER \
  -Fc \
  > /tmp/release_time_prod.dump

aws s3 cp \
  /tmp/release_time_prod.dump \
  s3://jutonz-homepage-prod-db-backups/release_time_prod.dump

rm /tmp/release_time_prod.dump
