# Servidor proxy Squid com Docker Compose

Este projeto executa um proxy HTTP/HTTPS [Squid](https://www.squid-cache.org/)
(Alpine 3.21, Squid 6.x) em TCP na porta `3128`. O mesmo serviço funciona de
duas formas, escolhidas pela variável `PROXY_MODE`:

| Modo               | `PROXY_MODE` | Comportamento                                                       |
| ------------------ | ------------ | ------------------------------------------------------------------- |
| Com autenticação   | `auth`       | Padrão. Exige usuário e senha (HTTP Basic) de `artifacts/passwords`. |
| Sem autenticação   | `noauth`     | Proxy aberto: aceita requisições de **qualquer origem** sem senha.  |

## Estrutura

```
proxy/
  Dockerfile           # alpine:3.21 + squid + apache2-utils (htpasswd)
  compose.yaml         # serviço "proxy"
  entrypoint.sh        # valida PROXY_MODE e inicia o Squid em primeiro plano
  .env.example         # modelo do arquivo .env
  config/
    common.conf        # porta, ACLs de portas seguras, logs, cache em memória
    squid-auth.conf    # modo auth (basic_ncsa_auth)
    squid-noauth.conf  # modo noauth (http_access allow all)
  artifacts/
    passwords          # usuários htpasswd (criado por você; ignorado pelo git)
```

As configurações de `config/` são copiadas para a imagem em
`/etc/squid/proxy/`. O diretório `artifacts/` é montado somente leitura em
`/run/proxy-auth`; no modo `auth`, o entrypoint copia `passwords` para
`/etc/squid/passwords` com dono `squid` e permissão `0400`, e o Squid roda os
helpers de autenticação como usuário `squid`.

## Pré-requisitos

- Docker Engine com Docker Compose v2 (`docker compose version`);
- porta TCP `3128` livre no host e liberada no firewall apenas para quem deve
  usar o proxy.

## Escolher o modo

Copie o modelo e ajuste `PROXY_MODE`:

```sh
cp .env.example .env
# edite .env: PROXY_MODE=auth  ou  PROXY_MODE=noauth
```

Sem `.env`, o modo é `auth`. Também é possível escolher na linha de comando,
o que tem precedência sobre o `.env`:

```sh
PROXY_MODE=noauth docker compose up -d
```

Ao trocar de modo, recrie o contêiner com `docker compose up -d`. Um valor
diferente de `auth` ou `noauth` faz o contêiner encerrar com erro.

## Modo com autenticação (`auth`)

### Criar usuários

Os comandos abaixo usam o `htpasswd` da própria imagem, executado com o seu
UID para que o arquivo continue pertencendo a você. Construa a imagem antes
(`docker compose build`). O `htpasswd` pede a senha de forma interativa, sem
gravá-la no histórico do shell.

Primeiro usuário (`-c` cria o arquivo; não use `-c` depois, pois ele
sobrescreve o arquivo):

```sh
docker compose run --rm --no-deps --user "$(id -u):$(id -g)" \
  -v "$PWD/artifacts:/work" proxy htpasswd -B -c /work/passwords usuario1
chmod 600 artifacts/passwords
```

Usuários adicionais ou troca de senha de um usuário existente:

```sh
docker compose run --rm --no-deps --user "$(id -u):$(id -g)" \
  -v "$PWD/artifacts:/work" proxy htpasswd -B /work/passwords usuario2
```

Remover um usuário:

```sh
docker compose run --rm --no-deps --user "$(id -u):$(id -g)" \
  -v "$PWD/artifacts:/work" proxy htpasswd -D /work/passwords usuario2
```

As senhas são gravadas com bcrypt (`-B`), aceito pelo helper
`basic_ncsa_auth`. Para listar os usuários sem expor os hashes, use
`cut -d: -f1 artifacts/passwords`.

### Iniciar

```sh
docker compose up -d --build
docker compose ps
docker compose logs -f proxy
```

O contêiner não inicia em modo `auth` se `artifacts/passwords` não existir ou
estiver vazio. Depois de alterar usuários ou senhas, aplique a mudança com:

```sh
docker compose restart proxy
```

### Testar

```sh
# sem credenciais: 407 Proxy Authentication Required
curl -sI -x http://127.0.0.1:3128 http://example.com | head -1

# com credenciais: 200 (read -s evita a senha no histórico do shell)
read -rs SENHA
curl -sI -x http://127.0.0.1:3128 --proxy-user "usuario1:$SENHA" https://example.com | head -1
unset SENHA
```

## Modo sem autenticação (`noauth`)

```sh
PROXY_MODE=noauth docker compose up -d --build
curl -sI -x http://127.0.0.1:3128 https://example.com | head -1
```

> **Atenção:** neste modo o proxy é aberto e aceita conexões de qualquer
> endereço. Exposto na internet, ele será descoberto e usado por terceiros
> (spam, abuso, ataques atribuídos ao seu IP). Use-o apenas em rede isolada,
> atrás de VPN ou com o firewall do host restringindo quem acessa a porta
> `3128`. O contêiner registra um `AVISO` nos logs ao iniciar assim.

Exemplo de restrição no host com `iptables` (Docker publica portas pela
cadeia `DOCKER-USER`), permitindo somente a rede `192.168.0.0/24`:

```sh
sudo iptables -I DOCKER-USER -p tcp --dport 3128 ! -s 192.168.0.0/24 -j DROP
```

Outra opção é publicar a porta apenas em uma interface específica, trocando
`"3128:3128/tcp"` por `"<IP_DA_INTERFACE>:3128:3128/tcp"` em `compose.yaml`.

## Configurar clientes

Linha de comando (Linux/macOS):

```sh
export http_proxy=http://<IP_SERVIDOR>:3128
export https_proxy=http://<IP_SERVIDOR>:3128
# modo auth: http://usuario:senha@<IP_SERVIDOR>:3128
```

Navegadores e sistemas operacionais: configure proxy HTTP manual com host
`<IP_SERVIDOR>`, porta `3128`, e marque "usar este proxy também para HTTPS".
No modo `auth`, o navegador solicita usuário e senha na primeira requisição.

O tráfego HTTPS passa como túnel `CONNECT`, sem inspeção do conteúdo. Apenas a
porta `443` é aceita para `CONNECT`; requisições HTTP são aceitas nas portas
padrão do Squid (`80`, `21`, `443`, `70`, `210`, `280`, `488`, `591`, `777` e
`1025-65535`).

## Logs e cache

O log de acesso vai para a saída padrão e o log do Squid para a saída de erro;
ambos aparecem em `docker compose logs proxy`. No modo `auth`, o nome do
usuário aparece em cada linha de acesso. O cache é somente em memória
(`cache_mem 64 MB`), sem volume em disco, e o cabeçalho `X-Forwarded-For` é
removido das requisições encaminhadas.

## Parar

```sh
docker compose down
```

## Verificações

```sh
docker compose config
PROXY_MODE=noauth docker compose config
docker compose build
docker compose run --rm --no-deps proxy squid -k parse -f /etc/squid/proxy/squid-auth.conf
docker compose run --rm --no-deps proxy squid -k parse -f /etc/squid/proxy/squid-noauth.conf
```

O `squid -k parse` só valida a sintaxe e não inicia o proxy.

## Segurança

- Nunca faça commit, cole em tickets ou exiba `artifacts/passwords`; ele está
  no `.gitignore` e no `.dockerignore`. Mantenha-o com permissão `0600`.
- A autenticação Basic envia usuário e senha codificados em base64, não
  criptografados, entre o cliente e o proxy. Use o modo `auth` em rede
  confiável, através do WireGuard/OpenVPN deste repositório, ou restrinja o
  acesso pelo firewall.
- O contêiner remove todas as capabilities e readiciona apenas `CHOWN`,
  `DAC_OVERRIDE`, `FOWNER`, `SETGID` e `SETUID`, necessárias para copiar o
  arquivo de senhas e para o Squid trocar para o usuário `squid`; também usa
  `no-new-privileges`.
