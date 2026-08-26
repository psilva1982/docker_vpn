# Relatório da correção final — servidor WireGuard em Docker Compose

## Status

CONCLUÍDO_COM_VALIDAÇÃO_DINÂMICA_PENDENTE

## Arquivos alterados

- `.dockerignore`: exclui `artifacts/` do contexto de build.
- `compose.yaml`: mantém `cap_drop: [ALL]` e concede exatamente
  `NET_ADMIN` e `DAC_OVERRIDE` em `cap_add`.
- `README.md`: documenta a checagem segura de permissões e a validação
  sanitizada de `wg-quick strip`.
- `.superpowers/sdd/2026-08-25-wireguard-container/task-3-report.md`:
  registra que a validação dinâmica continua pendente.
- Este relatório.

Os conteúdos de `artifacts/*.conf` não foram alterados.

## Permissões verificadas

A verificação por `stat`, sem ler os arquivos, confirmou:

- `artifacts/wg-server.conf`: `0600`
- `artifacts/wg-client-1.conf`: `0600`
- `artifacts/wg-client-2.conf`: `0600`
- `artifacts/wg-client-3.conf`: `0600`

## Validações

- `docker compose config` concluiu com sucesso e renderizou:
  - `cap_drop: ALL`;
  - `cap_add: NET_ADMIN` e `DAC_OVERRIDE`;
  - somente a porta UDP `51820`;
  - os sysctls IPv4 e IPv6 de encaminhamento;
  - a montagem de `wg0.conf` como somente leitura.
- A checagem estática dos blocos de comando do README passou: eles não contêm
  `PrivateKey` nem `PresharedKey`, validam `Address`, `ListenPort` e
  exatamente três peers apenas por confirmações de estado.
- `.dockerignore` foi verificado com a regra exata `artifacts/`.

## Limitações e preocupações

- A validação dinâmica de `wg-quick strip` não passou neste ambiente e
  permanece pendente. A tentativa como raiz do contêiner retornou
  `/etc/wireguard/wg0.conf: Permission denied`, compatível com Docker
  rootless/user namespaces que não mapeiam a raiz do contêiner ao proprietário
  do arquivo host em modo `0600`.
- A tentativa como UID/GID do proprietário também não é uma alternativa
  aceitável: `wg-quick` solicitou `sudo`, que não existe na imagem. As
  permissões dos artefatos não foram relaxadas.
- Se o ambiente bloquear a criação de namespaces de rede, a validação também
  deve continuar pendente e ser executada em um host/runner autorizado.
- Não foram executados `docker compose up`, `wg-quick up`, commits ou
  alterações no conteúdo das configurações.

## Correção DAC_OVERRIDE

- `compose.yaml` mantém `cap_drop: [ALL]` e passa a conceder exatamente
  `NET_ADMIN` e `DAC_OVERRIDE` em `cap_add`.
- A reexecução de `docker compose config` confirmou `cap_drop: ALL`, as duas
  capabilities exatas, UDP `51820`, os dois sysctls e o volume como somente
  leitura.
- `DAC_OVERRIDE` é necessária para o processo do contêiner ler o bind mount
  `0600`; não concede escrita porque `wg0.conf` é `:ro` e nenhum outro caminho
  do host é montado.
- A validação dinâmica continua pendente: não foram executados
  `docker compose up` nem `wg-quick up`.
