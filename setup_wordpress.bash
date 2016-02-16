#!/usr/bin/env bash
# version: 1.1.2

function setup {
  app=$1

  # Args
  if [ -z "${app}" ]; then
    echo "Usage: $0 {app}" && exit 1
  fi

  # Check app
  dokku apps | grep ${app} || ( echo "${app}: app doesn't exist" >&2 && exit 2 )

  # Setup DB
  if [ -z "$(dokku mariadb:list | grep ${app})" ]; then
    echo "---> Database create..."
    dokku mariadb:create ${app}
  else
    echo "---> Database already exists. Skipping."
  fi

  echo "---> Database link..."
  dokku mariadb:link ${app} ${app}

  # Setup DATA volume
  if [ -z "$(dokku volume:list ${app} | grep ':/data')" ]; then
    echo "---> Volume /data setup..."
    dokku volume:add ${app} /data
  else
    echo "---> Volume ${app}-data is already linked. Skipping."
  fi

  # Setup WP-CONTENT volume
  if [ -z "$(dokku volume:list ${app} | grep ':/app/wp-content/uploads')" ]; then
    echo "---> Volume /app/wp-content/uploads setup..."
    dokku volume:add ${app} /app/wp-content/uploads
  else
    echo "---> Volume ${app}-content-uploads is already linked. Skipping."
  fi

  echo ""
  echo "===> It's done! Wordpress ready for ${app}. Visit:"
  echo "     $(dokku url ${app})"
}

setup $1
