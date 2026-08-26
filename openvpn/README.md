# Servidor OpenVPN com Docker Compose

Este projeto executa um servidor OpenVPN em UDP na porta `1194`. A imagem
usa o perfil `artifacts/server.ovpn`, que já contém a PKI necessária.

## Pré-requisitos

- Docker Engine com Docker Compose v2 (`docker compose version`);
- host Linux com o dispositivo `/dev/net/tun` disponível;
- porta UDP `1194` liberada no firewall e, se aplicável, encaminhada pelo
  roteador/NAT para este host.

## Iniciar o servidor

Na raiz do projeto, construa a imagem e inicie o serviço em segundo plano:

```sh
docker compose up -d --build
```

Confira o estado e acompanhe os logs:

```sh
docker compose ps
docker compose logs -f openvpn
```

O estado das atribuições de IP do OpenVPN é mantido no volume
`openvpn-state`, portanto ele permanece entre recriações do contêiner.

## Conectar um cliente

1. Edite `artifacts/client.ovpn` e substitua `<IP_SERVIDOR>` pelo endereço IP
   público ou nome DNS do servidor.
2. Importe o perfil no cliente OpenVPN.
3. Informe qualquer usuário e senha somente para este ambiente de teste.

O perfil de cliente já aponta para UDP/1194 e usa a mesma CA do perfil de
servidor.

## Parar e remover

Para parar o serviço sem apagar o estado de atribuição de IP:

```sh
docker compose down
```

Para remover também esse estado persistente:

```sh
docker compose down -v
```

## Verificações úteis

```sh
docker compose config
docker compose build
```

## Segurança e limitações

- `artifacts/server.ovpn` contém uma chave privada e não deve ser publicado
  nem reutilizado em produção.
- O `artifacts/auth.bat` original é um script Windows que aceita qualquer
  credencial. O `Dockerfile` preserva explicitamente esse comportamento de
  teste usando `/bin/true`; substitua-o por autenticação real antes de uso em
  produção.
- O Compose habilita encaminhamento IPv4 no namespace do contêiner. Para
  fornecer acesso dos clientes à Internet ou a outras redes, ainda será
  necessário definir as rotas, regras de firewall/NAT e diretivas OpenVPN
  apropriadas para a sua infraestrutura.
