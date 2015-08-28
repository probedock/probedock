# encoding: utf-8

##
# Backup Generated: probedock
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t probedock [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#
Model.new(:probedock, 'Probe Dock backup') do

  database PostgreSQL do |db|
    db.name               = ENV['PROBE_DOCK_DATABASE_NAME']
    db.username           = ENV['PROBE_DOCK_DATABASE_USERNAME']
    db.password           = ENV['PROBE_DOCK_DATABASE_PASSWORD']
    db.host               = ENV['PROBE_DOCK_DATABASE_HOST']
    db.port               = 5432
  end

  compress_with Gzip

  store_with Local do |local|
    local.path = '/var/lib/lair/backup/local'
    local.keep = 3
  end
end
