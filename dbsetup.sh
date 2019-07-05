#!/bin/bash

if [[ -z "${DATABASE_URL}" ]]; then
  bundle exec rails db:setup
else
  echo "Skipping database setup (DATABASE_URL is set)..."
fi
