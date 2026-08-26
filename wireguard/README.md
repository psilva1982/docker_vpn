# WireGuard em Docker Compose

Este projeto executa um servidor WireGuard pelo serviço `wireguard` definido em
`compose.yaml`. Os arquivos de configuração ficam em `artifacts/` e devem ser
tratados como segredos.

## Pré-requisitos

- Docker Engine com o plugin Docker Compose instalado.
- Módulo WireGuard disponível no kernel do host. O contêiner precisa das
  capacidades `NET_ADMIN` para configurar a interface e `DAC_OVERRIDE` para
  ler o bind mount `0600`.
- UDP `51820` liberada no firewall e encaminhada pelo NAT do roteador para o
  host, quando o servidor estiver atrás de NAT.

Antes de distribuir os clientes, substitua o marcador `<IP_SERVIDOR>` em cada
`artifacts/wg-client-*.conf` pelo IP público ou pelo nome DNS do host. Faça essa
alteração em uma cópia segura e distribua os arquivos de cliente somente por um
canal confiável.

Não inclua chaves privadas neste README, em logs, tickets ou mensagens de
diagnóstico. Mantenha `artifacts/wg-server.conf` e os arquivos
`artifacts/wg-client-*.conf` com permissões `0600`.

`DAC_OVERRIDE` permite ignorar checagens DAC de leitura e escrita. Neste serviço,
o bind mount `wg0.conf` permanece `:ro` e nenhum outro caminho do host é montado,
mitigando a exposição sem eliminar essa capacidade.

## Validar a configuração

Renderize e valide a configuração Compose:

```sh
docker compose config
```

Confira as permissões sem exibir o conteúdo das configurações:

```sh
for file in artifacts/wg-server.conf artifacts/wg-client-1.conf artifacts/wg-client-2.conf artifacts/wg-client-3.conf; do
  [ "$(stat -c '%a' "$file")" = 600 ] || exit 1
  stat -c '%a %n' "$file"
done
```

Para verificar o parse da configuração do servidor sem criar ou ativar a
interface `wg0`, use `wg-quick strip`. O comando abaixo só exibe confirmações,
sem imprimir conteúdo da configuração; confirma `Address`, `ListenPort` e
exatamente três peers. Ele não executa `wg-quick up` nem cria a interface:

```sh
docker compose run --rm --no-deps --entrypoint /bin/sh wireguard -ec '
  config=/etc/wireguard/wg0.conf
  stripped=/tmp/wg0.stripped
  wg-quick strip "$config" > "$stripped"
  address_count=$(awk -F= "/^[[:space:]]*Address[[:space:]]*=/ { count++ } END { print count + 0 }" "$config")
  listen_port_count=$(awk -F= "/^[[:space:]]*ListenPort[[:space:]]*=/ { count++ } END { print count + 0 }" "$stripped")
  peer_count=$(awk "/^\[Peer\]$/ { count++ } END { print count + 0 }" "$stripped")
  test "$address_count" -ge 1
  test "$listen_port_count" -eq 1
  test "$peer_count" -eq 3
  printf "%s\n" "Address: presente" "ListenPort: presente" "Peers: $peer_count"
'
```

Quando o ambiente não permitir a criação de namespaces de rede do contêiner,
a validação dinâmica com `wg-quick strip` fica pendente. Execute-a depois em
um host ou runner com essa permissão; não substitua essa etapa por `wg-quick up`.

`DAC_OVERRIDE` permite ao processo do contêiner ler o bind mount `0600` sem
restaurar capabilities padrão. Se uma engine rootless ou user namespaces ainda
impedir o mapeamento do arquivo, mantenha as permissões e valide em um runner
rootful com mapeamento de identidade apropriado.

## Construir e iniciar

```sh
docker compose build
docker compose up -d
```

Acompanhe os logs do serviço:

```sh
docker compose logs -f wireguard
```

## Parar

```sh
docker compose down
```

Para uma validação consolidada antes da inicialização, execute:

```sh
docker compose config && docker compose run --rm --no-deps --entrypoint /bin/sh wireguard -ec '
  config=/etc/wireguard/wg0.conf
  stripped=/tmp/wg0.stripped
  wg-quick strip "$config" > "$stripped"
  address_count=$(awk -F= "/^[[:space:]]*Address[[:space:]]*=/ { count++ } END { print count + 0 }" "$config")
  listen_port_count=$(awk -F= "/^[[:space:]]*ListenPort[[:space:]]*=/ { count++ } END { print count + 0 }" "$stripped")
  peer_count=$(awk "/^\[Peer\]$/ { count++ } END { print count + 0 }" "$stripped")
  test "$address_count" -ge 1
  test "$listen_port_count" -eq 1
  test "$peer_count" -eq 3
  printf "%s\n" "Address: presente" "ListenPort: presente" "Peers: $peer_count"
'
```
