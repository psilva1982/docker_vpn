# Relatório do ajuste DAC_OVERRIDE

## Arquivos alterados

O ajuste DAC foi aplicado nos seguintes arquivos:

- `compose.yaml`
- `README.md`
- `docs/superpowers/specs/2026-08-25-wireguard-container-design.md`
- `docs/superpowers/plans/2026-08-25-wireguard-container.md`

## Configuração alvo

- `cap_drop: ALL`
- `cap_add: NET_ADMIN` e `DAC_OVERRIDE`
- Volume de `wg0.conf` montado como somente leitura (`read-only`)
- Os quatro arquivos `artifacts/*.conf` permanecem com modo `0600` no host; somente `artifacts/wg-server.conf` é montado no contêiner como `/etc/wireguard/wg0.conf:ro`; os três arquivos de cliente não são montados.

## Validação

A validação `docker compose config` foi registrada pelo implementador anterior, mas não foi reexecutada neste ajuste.

A validação dinâmica com `wg-quick strip` permanece pendente/bloqueada por limitações de namespace.

Nenhuma VPN foi iniciada.
