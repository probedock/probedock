#!/bin/bash

# The PostgreSQL docker image creates a pg_hba.conf file with the following authentication configuration:
#     host all all 0.0.0.0/0 md5

# The following command replaces "md5" with "trust" so that any user is allowed access to any database
# without authentication. This simplifies configuration for this development environment.

sed -i 's/md5/trust/' /var/lib/postgresql/data/pg_hba.conf
