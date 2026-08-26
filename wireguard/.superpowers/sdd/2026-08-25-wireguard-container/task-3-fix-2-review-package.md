# Task 3 fix round 2 review package

## Finding under review

External `| sed` in the consolidated command could return success when `wg-quick strip` failed. The sanitization must preserve the validator's exit status.

## Amended README excerpt

```sh
docker compose run --rm --no-deps --entrypoint /bin/sh wireguard -ec 'sed -E "/^[[:space:]]*(PrivateKey|PresharedKey)[[:space:]]*=/d" /etc/wireguard/wg0.conf > /tmp/wg0.conf && grep -E "^[[:space:]]*Address[[:space:]]*=" /tmp/wg0.conf'

docker compose run --rm --no-deps --entrypoint /bin/sh wireguard -ec 'wg-quick strip /etc/wireguard/wg0.conf > /tmp/wg0.stripped && sed -E "/^[[:space:]]*(PrivateKey|PresharedKey)[[:space:]]*=/d" /tmp/wg0.stripped'

docker compose config && docker compose build wireguard && docker compose run --rm --no-deps --entrypoint /bin/sh wireguard -ec 'wg-quick strip /etc/wireguard/wg0.conf > /tmp/wg0.stripped && sed -E "/^[[:space:]]*(PrivateKey|PresharedKey)[[:space:]]*=/d" /tmp/wg0.stripped'
```
