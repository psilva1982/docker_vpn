# Servidor WireGuard em Docker Compose Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Disponibilizar o servidor definido em `artifacts/wg-server.conf` por meio de Docker Compose, com uma imagem local mínima e instruções seguras de operação.

**Architecture:** Uma imagem Alpine instala as ferramentas WireGuard de espaço de usuário e inicia a interface `wg0` por `wg-quick`. O Compose monta o arquivo do servidor em modo somente leitura, publica UDP 51820 e fornece a capacidade e os sysctls necessários no namespace do contêiner.

**Tech Stack:** Docker Engine, Docker Compose Specification, Alpine Linux, wireguard-tools, iproute2, iptables.

**Spec:** `docs/superpowers/specs/2026-08-25-wireguard-container-design.md`

## Global Constraints

- Usar exclusivamente `artifacts/wg-server.conf` como configuração do servidor; não copiar nem registrar chaves privadas na imagem.
- Publicar apenas `51820/udp` no host e conceder somente as capabilities Linux
  `NET_ADMIN` e `DAC_OVERRIDE`; a segunda permite ler o arquivo `0600` montado
  como somente leitura.
- O host precisa de suporte de kernel a WireGuard; a imagem não tenta instalar módulos de kernel.
- Validar com `docker compose config`, build da imagem e `wg-quick strip`; não ativar uma interface VPN durante a validação automatizada.
- Não há repositório Git neste diretório, portanto nenhuma etapa cria commit.

---

### Task 1: Criar a imagem do servidor

**Files:**
- Create: `Dockerfile`

**Interfaces:**
- Consumes: `/etc/wireguard/wg0.conf`, disponibilizado pelo volume do Compose.
- Produces: imagem local que executa `wg-quick up wg0`, aguarda sinais e executa `wg-quick down wg0` no encerramento.

- [ ] **Step 1: Criar o `Dockerfile` com as dependências estritamente necessárias**

```dockerfile
FROM alpine:3.21

RUN apk add --no-cache iproute2 iptables wireguard-tools

CMD ["/bin/sh", "-ec", "wg-quick up wg0; trap 'wg-quick down wg0; exit 0' INT TERM; while :; do sleep 3600 & wait $!; done"]
```

- [ ] **Step 2: Validar a sintaxe do Dockerfile através do build**

Run: `docker compose build wireguard`

Expected: a imagem termina o build com sucesso e contém `wg-quick`.

### Task 2: Declarar o serviço Compose

**Files:**
- Create: `compose.yaml`

**Interfaces:**
- Consumes: `Dockerfile` e `./artifacts/wg-server.conf`.
- Produces: serviço `wireguard` na porta UDP 51820 com `NET_ADMIN` e
  `DAC_OVERRIDE` (para ler o arquivo `0600`), sysctls de encaminhamento e
  reinicialização controlada.

- [ ] **Step 1: Criar o `compose.yaml`**

```yaml
services:
  wireguard:
    build:
      context: .
    cap_add:
      - NET_ADMIN
      - DAC_OVERRIDE
    cap_drop:
      - ALL
    ports:
      - "51820:51820/udp"
    restart: unless-stopped
    sysctls:
      net.ipv4.ip_forward: "1"
      net.ipv6.conf.all.forwarding: "1"
    volumes:
      - ./artifacts/wg-server.conf:/etc/wireguard/wg0.conf:ro
```

- [ ] **Step 2: Validar a interpretação do Compose**

Run: `docker compose config`

Expected: saída com um único serviço `wireguard`, porta alvo e publicada
`51820/udp`, volume com `read_only: true`, `cap_drop: ALL`, exatamente as
capabilities `NET_ADMIN` e `DAC_OVERRIDE`, e os dois sysctls.

### Task 3: Documentar uso e validar a configuração WireGuard

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: `compose.yaml`, `artifacts/wg-server.conf` e os três arquivos de cliente.
- Produces: instruções de pré-requisito, validação, inicialização/parada e preparação segura dos clientes.

- [ ] **Step 1: Criar o `README.md`**

O documento deve registrar estes comandos exatos:

```sh
docker compose config
docker compose build
docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf
docker compose up -d
docker compose logs -f wireguard
docker compose down
```

Também deve explicar que o módulo WireGuard deve estar disponível no host, que UDP 51820 precisa estar liberada no firewall/NAT e que `<IP_SERVIDOR>` em cada `artifacts/wg-client-*.conf` deve receber o IP público ou DNS do host antes da distribuição. O README não deve incluir nem imprimir chaves privadas.

- [ ] **Step 2: Verificar o parse não intrusivo da configuração do servidor**

Run: `docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf`

Expected: saída sem erro, contendo as diretivas `Address`, `ListenPort` e três peers; nenhum comando tenta criar a interface `wg0`.

- [ ] **Step 3: Executar a validação consolidada**

Run: `docker compose config && docker compose build wireguard && docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf`

Expected: os três comandos concluem sem erro. Caso Docker não esteja disponível ou o build esteja impedido pelo ambiente, registrar exatamente qual pré-requisito externo faltou e ainda executar toda validação estática disponível.
