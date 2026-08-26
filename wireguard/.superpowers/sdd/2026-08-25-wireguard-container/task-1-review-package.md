# Task 1 review package

No Git base/head exists because this workspace is not a Git repository. This package contains the complete newly created file, equivalent to the creation diff.

## Created file: Dockerfile

```dockerfile
FROM alpine:3.21

RUN apk add --no-cache iproute2 iptables wireguard-tools

CMD ["/bin/sh", "-ec", "wg-quick up wg0; trap 'wg-quick down wg0; exit 0' INT TERM; while :; do sleep 3600 & wait $!; done"]
```
