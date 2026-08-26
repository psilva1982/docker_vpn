# Task 3 — Relatório

## Status

DONE_WITH_CONCERNS

## Arquivos alterados

- Criado `README.md`.
- Nenhum artefato WireGuard foi alterado.

## Decisões

- Documentados literalmente os comandos Compose exigidos para `config`, `build`,
  `run --rm --no-deps --entrypoint`, `up -d`, `logs -f` e `down`.
- Incluídos os pré-requisitos de módulo WireGuard no kernel, UDP 51820 no
  firewall/NAT e substituição de `<IP_SERVIDOR>` nos três arquivos de cliente.
- A documentação alerta contra exposição de chaves e não contém valores de
  chave privada, pública ou pré-compartilhada.
- A validação `wg-quick strip` é explicitamente descrita como não intrusiva,
  sem ativar ou criar `wg0`.

## Validação

Todos os comandos foram executados a partir da raiz do projeto. Saídas abaixo
foram mantidas sem qualquer conteúdo de chave.

- `docker compose config` — sucesso; Compose renderizado com o serviço
  `wireguard`, porta UDP 51820 e montagem somente leitura de
  `artifacts/wg-server.conf`.
- `docker compose build wireguard` — sucesso; imagem
  `wireguard-wireguard` construída.
- `rg -n 'docker compose|51820|IP_SERVIDOR|WireGuard|wg0|PrivateKey|PresharedKey' README.md` — sucesso; confirmou a presença das instruções
  exigidas. A busca não encontrou valores de chave.
- `docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf` — não executou no ambiente atual:
  `bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted`.

## Preocupações

- A validação dinâmica de `wg-quick strip` ainda precisa ser executada em um
  host/runner com permissão para configurar a rede de namespace do contêiner.
  O comando foi tentado com remoção de linhas `PrivateKey` e `PresharedKey` da
  saída para evitar qualquer impressão de segredo.
- Não foram executados `up`, `logs` ou `down`, pois a tarefa exige apenas a
  documentação desses comandos e a validação não intrusiva.



## Correção da revisão — round 1

- Removido do README o comando de strip sem filtragem; a saída agora remove PrivateKey e PresharedKey.
- Adicionada verificação separada de Address contra /etc/wireguard/wg0.conf, também sanitizada antes da exibição.
- A saída sanitizada de wg-quick strip agora é descrita como contendo ListenPort e três peers.

### Validação focada

- rg confirmou os comandos sanitizados e a distinção entre a checagem estática de Address e o parse sanitizado de strip.
- As ocorrências de wg-quick strip incluem filtro sed para campos secretos.
- O comando sanitizado de wg-quick strip continua bloqueado: bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted.


## Correção da revisão — round 2

- Removidos os pipes executados no host, que poderiam mascarar falhas sem `pipefail`.
- Os comandos agora usam `--entrypoint /bin/sh -ec`: `wg-quick strip` grava em `/tmp/wg0.stripped` no contêiner efêmero e só depois sanitiza a saída; falhas retornam código não zero.
- A checagem de `Address` também grava a configuração sanitizada em `/tmp/wg0.conf` no contêiner antes do `grep`, preservando o status do comando.
- A validação consolidada foi atualizada para usar a mesma estrutura, sem pipe no host.

### Validação focada

- Leitura focada do README confirmou que os comandos sanitizados usam `-ec`, arquivos temporários internos e não usam pipe externo.
- Nenhum artefato WireGuard foi alterado.
- A execução dinâmica continua condicionada ao ambiente que bloqueou `bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted`.

## Correção da revisão — final

- A validação dinâmica de `wg-quick strip` permanece pendente: ela não passou
  neste ambiente, que bloqueia a configuração de namespace de rede do
  contêiner com `bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted`.
- O README passa a deixar essa limitação explícita e fornece uma validação que
  só emite confirmações de `Address`, `ListenPort` e da contagem de peers,
  sem exibir conteúdo de configuração.

- Na execução final após aplicar `0600`, a validação como raiz do contêiner
  retornou `/etc/wireguard/wg0.conf: Permission denied`; a alternativa com o
  UID/GID proprietário não é viável porque `wg-quick` solicitou `sudo`, que
  não está na imagem. Portanto, a validação dinâmica permanece pendente e não
  foi declarada aprovada.
