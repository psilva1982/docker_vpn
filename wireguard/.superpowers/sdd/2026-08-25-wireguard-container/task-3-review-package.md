# Task 3 review package

No Git base/head exists because this workspace is not a Git repository. This package contains the complete newly created file, equivalent to the creation diff.

## Created file: README.md

```markdown
# WireGuard em Docker Compose

Este projeto executa um servidor WireGuard pelo serviço `wireguard` definido em
`compose.yaml`. Os arquivos de configuração ficam em `artifacts/` e devem ser
tratados como segredos.

## Pré-requisitos

- Docker Engine com o plugin Docker Compose instalado.
- Módulo WireGuard disponível no kernel do host. O contêiner precisa da
  capacidade `NET_ADMIN` para configurar a interface.
- UDP `51820` liberada no firewall e encaminhada pelo NAT do roteador para o
  host, quando o servidor estiver atrás de NAT.

Antes de distribuir os clientes, substitua o marcador `<IP_SERVIDOR>` em cada
`artifacts/wg-client-*.conf` pelo IP público ou pelo nome DNS do host. Faça essa
alteração em uma cópia segura e distribua os arquivos de cliente somente por um
canal confiável.

Não inclua chaves privadas neste README, em logs, tickets ou mensagens de
diagnóstico. Mantenha `artifacts/wg-server.conf` e os arquivos
`artifacts/wg-client-*.conf` com permissões restritas.

## Validar a configuração

Renderize e valide a configuração Compose:

```sh
docker compose config
```

Para verificar o parse da configuração do servidor sem criar ou ativar a
interface `wg0`, use `wg-quick strip`. A saída deve conter as diretivas
`Address` e `ListenPort` e três blocos de peer; o comando não deve executar
`wg-quick up` nem criar a interface:

```sh
docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf
```

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
docker compose config && docker compose build wireguard && docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf
```
```
