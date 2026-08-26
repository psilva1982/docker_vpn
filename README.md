# Servidores VPN com Docker Compose

Este repositório reúne duas implantações independentes de VPN em contêineres:

- [WireGuard](wireguard/README.md), exposto em UDP `51820`;
- [OpenVPN](openvpn/README.md), exposto em UDP `1194`.

Cada diretório pode ser operado isoladamente. Consulte o README do serviço antes de alterar perfis, capabilities, portas ou regras de rede.

## Pré-requisitos

- Docker Engine e Docker Compose v2;
- um host Linux com suporte ao protocolo escolhido;
- portas UDP liberadas no firewall e encaminhadas pelo roteador/NAT, quando aplicável;
- permissões para o contêiner configurar interfaces e encaminhamento de IP.

Para WireGuard, o módulo precisa estar disponível no kernel do host. Para OpenVPN, o host precisa disponibilizar `/dev/net/tun`.

## WireGuard

O servidor é definido em `wireguard/compose.yaml` e utiliza `wireguard/artifacts/wg-server.conf` como montagem somente leitura. Os perfis de cliente ficam em `wireguard/artifacts/wg-client-*.conf`.

```sh
cd wireguard
docker compose config
docker compose build
docker compose up -d
docker compose logs -f wireguard
```

Interrompa o serviço com `docker compose down`. Antes de distribuir um perfil de cliente, substitua `<IP_SERVIDOR>` pelo IP público ou DNS do host em uma cópia mantida em local seguro. Para validar o parse do servidor sem ativar a interface, execute o comando `wg-quick strip` documentado em [wireguard/README.md](wireguard/README.md).

## OpenVPN

O serviço está em `openvpn/docker-compose.yml`; a imagem usa `openvpn/artifacts/server.ovpn`, e o cliente de exemplo está em `openvpn/artifacts/client.ovpn`.

```sh
cd openvpn
docker compose up -d --build
docker compose ps
docker compose logs -f openvpn
```

Use `docker compose down` para interromper sem remover o estado persistido. `docker compose down -v` também remove o volume `openvpn-state` e deve ser usado somente quando essa remoção for intencional.

## Segurança

Os arquivos em `artifacts/` podem conter chaves privadas e devem permanecer fora de commits, logs, tickets e mensagens. Mantenha as configurações WireGuard com permissão `0600` e distribua perfis de cliente apenas por canais confiáveis.

A autenticação OpenVPN incluída é exclusiva para testes; antes de qualquer uso em produção, implemente autenticação real e configure rotas, firewall e NAT de acordo com a infraestrutura.
