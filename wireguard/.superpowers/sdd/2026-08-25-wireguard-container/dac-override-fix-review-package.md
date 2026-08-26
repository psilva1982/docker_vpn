# DAC_OVERRIDE correction review package

## Finding under review

With `cap_drop: ALL`, `cap_add: NET_ADMIN`, and a `0600` bind-mounted `wg0.conf`, the service may be unable to read its configuration because it lacks DAC override capability.

## Authorized resolution

The user explicitly authorized exactly one additional capability: `DAC_OVERRIDE`. The final Compose configuration must drop all defaults and add exactly `NET_ADMIN` plus `DAC_OVERRIDE`; the bind mount remains read-only and no other host path is mounted. README, spec, and plan must describe the rationale. Artifact modes stay `0600`, artifact contents are out of scope and must never be read.

## Evidence

Read `dac-override-fix-report.md` in this directory. It records a successful `docker compose config` with the two exact capabilities and `0600` modes for the four artifacts; dynamic validation remains pending.
