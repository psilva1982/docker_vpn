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

## Binding global constraints

- Use somente a configuração montada em `/etc/wireguard/wg0.conf`; nunca copie chaves privadas para a imagem.
- O host, não o contêiner, precisa oferecer o suporte de kernel WireGuard.
- Não existe repositório Git: não crie commits nem tente criar um worktree.
- Use Serena MCP e Context7. Antes de qualquer edição, leia as instruções Serena, ative `/home/severo/Documents/projetos/paulo/vpn/wireguard` e consulte Context7 sobre a imagem Alpine e a instalação de pacotes necessários.
