#!/bin/bash
set -e

cd /app

# Initialize the SQLite3 database from schema.rb if not already present
if [ ! -s db/hacmecasino_development.db ]; then
    echo "[*] Initializing database..."
    rake db:schema:load RAILS_ENV=development
fi

echo "[*] Hacme Casino starting on http://0.0.0.0:3000 ..."
exec ruby script/server -p 3000
