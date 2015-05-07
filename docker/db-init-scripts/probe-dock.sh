echo "Starting postgres"
mkdir -p /tmp/pg-setup
chown -R postgres:postgres /tmp/pg-setup
PGHOST=/tmp/pg-setup gosu postgres pg_ctl -o "-c listen_addresses='' -c unix_socket_directories='/tmp/pg-setup'" -l "/tmp/pg-setup/setup.log" -w start

echo "Creating the database user"
PGHOST=/tmp/pg-setup gosu postgres psql -U postgres -c "CREATE USER $PROBE_DOCK_DATABASE_USERNAME PASSWORD '${PROBE_DOCK_DATABASE_PASSWORD}'"

echo "Creating the database"
PGHOST=/tmp/pg-setup gosu postgres createdb -U postgres -O $PROBE_DOCK_DATABASE_USERNAME $PROBE_DOCK_DATABASE_NAME

echo "Stopping postgres"
gosu postgres pg_ctl -m fast -w stop
