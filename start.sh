#!/usr/bin/env sh
rm -f /usr/src/app/tmp/pids/server.pid
rails server -e production -b 0.0.0.0
