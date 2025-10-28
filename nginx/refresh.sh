#!/bin/sh
set -eu
CONF_TEMPLATE=/etc/nginx/templates/nginx.conf.tmpl
CONF_OUTPUT=/etc/nginx/conf.d/default.conf

ACTIVE_TARGET=${ACTIVE_TARGET:-blue}
APP_PORT=${APP_PORT:-3000}

if [ "$ACTIVE_TARGET" = "blue" ]; then
  PRIMARY_NODE="blue_service"
  SECONDARY_NODE="green_service"
else
  PRIMARY_NODE="green_service"
  SECONDARY_NODE="blue_service"
fi

sed -e "s/PRIMARY_NODE/${PRIMARY_NODE}/g" \
    -e "s/SECONDARY_NODE/${SECONDARY_NODE}/g" \
    -e "s/PRIMARY_PORT/${APP_PORT}/g" \
    -e "s/SECONDARY_PORT/${APP_PORT}/g" \
    "$CONF_TEMPLATE" > "$CONF_OUTPUT"

echo "♻️ Reloading Nginx with ${PRIMARY_NODE} as primary..."
nginx -t && nginx -s reload
