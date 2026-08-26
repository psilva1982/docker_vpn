# Final review package — WireGuard container

No Git range exists because this workspace is not a Git repository. Review the following complete work product directly; all three files were created by this plan.

## Files in scope

- `Dockerfile`: Alpine 3.21 with `iproute2`, `iptables`, `wireguard-tools`, and `wg-quick up/down` lifecycle command.
- `compose.yaml`: `wireguard` service, local build, only `NET_ADMIN`, published `51820/udp`, restart policy, forwarding sysctls, and read-only `artifacts/wg-server.conf` bind mount.
- `README.md`: prerequisites, safe configuration validation, build/start/log/stop commands, client endpoint guidance, and secret-handling warnings.

## Validation evidence

- `docker compose config`: successful, with expected service, port, capability, sysctls and read-only bind mount.
- `docker compose build wireguard`: successful in Task 3.
- Dynamic `wg-quick strip`: attempted but blocked by `bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted`; README contains a command that preserves its exit status and suppresses `PrivateKey`/`PresharedKey` from terminal output.

## Rulings to examine

1. The raw `wg-quick strip` command from the original plan was replaced by a sanitized command because its raw output can contain `PrivateKey`. This is required by the stronger no-secret rule.
2. Sanitization now occurs in an ephemeral `--rm` container via `/tmp/wg0.stripped`, chained by `sh -ec` and `&&`, so it does not mask a `wg-quick strip` failure.
