#/bin/bash

set -e

# Runing as postgres user

cd

aws s3 cp s3://jutonz-homepage-prod-db-backups/release-time_prod.dump release-time_prod.dump

# pg_restore returns nonzero code since some imports don't work. This is okay,
# so return true to keep container running (nonzero will kill it)
pg_restore -d release-time_prod --role=homepage release-time_prod.dump || true
