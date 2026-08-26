### Task 2: Declarar o serviço Compose

**Files:**
- Create: `compose.yaml`

**Interfaces:**
- Consumes: `Dockerfile` e `./artifacts/wg-server.conf`.
- Produces: serviço `wireguard` na porta UDP 51820 com `NET_ADMIN`, sysctls de encaminhamento e reinicialização controlada.

- [ ] **Step 1: Criar o `compose.yaml`**

```yaml
services:
  wireguard:
    build:
      context: .
    cap_add:
      - NET_ADMIN
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

Expected: saída com um único serviço `wireguard`, porta alvo e publicada `51820/udp`, volume com `read_only: true`, capability `NET_ADMIN` e os dois sysctls.

## Binding global constraints

- Usar exclusivamente `artifacts/wg-server.conf` como configuração do servidor; não copiar nem registrar chaves privadas na imagem.
- Publicar apenas `51820/udp` no host e conceder somente a capability Linux `NET_ADMIN`.
- O host precisa de suporte de kernel a WireGuard; a imagem não tenta instalar módulos de kernel.
- Não há repositório Git: não crie commits nem tente criar um worktree.
- Use Serena MCP e Context7. Antes de qualquer edição, leia as instruções Serena, ative `/home/severo/Documents/projetos/paulo/vpn/wireguard` e consulte Context7 sobre a especificação Docker Compose para portas UDP, capabilities, volumes read-only, sysctls e `restart`.
