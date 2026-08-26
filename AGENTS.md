# Repository Guidelines

## Project Structure & Module Organization

This repository contains two self-contained Docker Compose deployments:

- `openvpn/` provides the OpenVPN image, `docker-compose.yml`, and its usage guide.
- `wireguard/` provides the WireGuard image, `compose.yaml`, and its usage guide.
- Each service keeps sensitive server and client profiles in `artifacts/`.
- `wireguard/docs/superpowers/` contains the approved design and implementation plan; keep these records aligned with material architecture changes.

Run service commands from the applicable service directory, for example `cd wireguard`.

## Build, Test, and Development Commands

- `docker compose config` renders and statically validates the current Compose configuration.
- `docker compose build` builds the local VPN image.
- `docker compose up -d` starts the service; `docker compose logs -f wireguard` (or `openvpn`) follows logs.
- `docker compose down` stops the service. For OpenVPN, use `docker compose down -v` only when intentionally removing persisted IP-assignment state.

Before starting WireGuard, run the non-invasive parser check documented in `wireguard/README.md`; it uses `wg-quick strip` and must not activate `wg0`.

## Coding Style & Naming Conventions

Use two-space indentation for YAML. Keep Dockerfiles minimal, order package installation and setup in a single focused `RUN` instruction where practical, and use explicit image tags. Name Compose services after the protocol (`openvpn`, `wireguard`) and client profiles descriptively, such as `wg-client-1.conf`. Update the relevant README whenever operational behavior, ports, mounts, capabilities, or prerequisites change.

## Testing Guidelines

There is no application test framework. Validate every change with `docker compose config` and `docker compose build` in the affected directory. For WireGuard configuration changes, also perform the documented `wg-quick strip` check and confirm the expected peer count without printing configuration contents. Do not run `wg-quick up` merely to test parsing.

## Commit & Pull Request Guidelines

The existing history uses short, imperative summaries (for example, `Implement WireGuard and OpenVpn server in Docker Compose`). Keep commits focused by service and explain the operational impact in the pull request. Include validation commands and outcomes, link related issues when available, and call out any firewall, routing, capability, or configuration changes. Never include private keys, server addresses, or profile contents in commits, PR text, screenshots, or logs.

## Security & Configuration

Keep profile files at `0600`, replace `<IP_SERVIDOR>` only in secure distribution copies, and distribute client profiles through trusted channels. The bundled OpenVPN authentication behavior is explicitly test-only; production deployments require real authentication plus host firewall, routing, and NAT configuration.
