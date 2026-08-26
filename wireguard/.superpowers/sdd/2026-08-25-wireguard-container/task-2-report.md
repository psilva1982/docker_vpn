# Relatório da Task 2 — Declarar o serviço Compose

## Arquivos alterados

- `compose.yaml` (criado): serviço único `wireguard`.
- `.superpowers/sdd/2026-08-25-wireguard-container/task-2-report.md` (criado): este relatório.

## Decisões e implementação

O `compose.yaml` segue os valores exatos do briefing:

- build usando o contexto do projeto (`.`), consumindo o `Dockerfile` existente;
- única capability adicional: `NET_ADMIN`;
- única publicação no host: `51820:51820/udp`;
- `restart: unless-stopped`;
- encaminhamento IPv4 e IPv6 habilitado pelos dois sysctls solicitados;
- bind mount exclusivo de `./artifacts/wg-server.conf` para `/etc/wireguard/wg0.conf`, em modo somente leitura (`:ro`).

Não foram incluídas chaves, variáveis com segredos ou qualquer instalação de módulo de kernel.

Antes da edição, Serena foi inicializado e o projeto `/home/severo/Documents/projetos/paulo/vpn/wireguard` foi ativado. Context7 foi consultado após resolver `/docker/compose`; a documentação confirmou a estrutura `services`, publicação de portas e configuração Compose usada para este serviço.

## Validação

Comando executado:

```text
docker compose config
```

Resultado relevante (saída sanitizada, sem conteúdo de configuração privada):

```text
services:
  wireguard:
    cap_add:
      - NET_ADMIN
    ports:
      - target: 51820
        published: "51820"
        protocol: udp
    restart: unless-stopped
    sysctls:
      net.ipv4.ip_forward: "1"
      net.ipv6.conf.all.forwarding: "1"
    volumes:
      - source: .../artifacts/wg-server.conf
        target: /etc/wireguard/wg0.conf
        read_only: true
```

O comando terminou com código 0 e apresentou um único serviço `wireguard`.

## Preocupações

- A execução real depende de o host fornecer suporte de kernel a WireGuard e permissões para `NET_ADMIN`/sysctls; isso não é validado por `docker compose config`.
- A configuração do servidor é fornecida em runtime pelo bind mount; o arquivo deve existir no host antes de `docker compose up`.
