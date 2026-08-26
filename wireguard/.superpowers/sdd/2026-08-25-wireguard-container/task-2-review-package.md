# Task 2 review package

No Git base/head exists because this workspace is not a Git repository. This package contains the complete newly created file, equivalent to the creation diff.

## Created file: compose.yaml

```yaml
services:
  wireguard:
    build:
      context: .
    cap_add:
      - NET_ADMIN
    ports:
      - "51820:51820/udp"
    restart: unless-stopped
    sysctls:
      net.ipv4.ip_forward: "1"
      net.ipv6.conf.all.forwarding: "1"
    volumes:
      - ./artifacts/wg-server.conf:/etc/wireguard/wg0.conf:ro
```
