#!/bin/sh
set -eu

# Any explicit command (e.g. `squid -k parse ...` or `htpasswd ...`) runs as-is.
if [ "$#" -gt 0 ]; then
  exec "$@"
fi

PROXY_MODE="${PROXY_MODE:-auth}"
CONFIG="/etc/squid/proxy/squid-${PROXY_MODE}.conf"

case "$PROXY_MODE" in
  auth)
    SOURCE=/run/proxy-auth/passwords
    if [ ! -s "$SOURCE" ]; then
      echo "PROXY_MODE=auth exige o arquivo artifacts/passwords (htpasswd) não vazio." >&2
      exit 1
    fi
    # The host file stays 0600 under the operator's uid; hand the helper a
    # private copy readable only by the squid user.
    install -o squid -g squid -m 0400 "$SOURCE" /etc/squid/passwords
    ;;
  noauth)
    echo "AVISO: PROXY_MODE=noauth aceita conexões de qualquer origem sem autenticação." >&2
    ;;
  *)
    echo "PROXY_MODE inválido: '$PROXY_MODE' (use 'auth' ou 'noauth')." >&2
    exit 1
    ;;
esac

exec squid --foreground -f "$CONFIG"
