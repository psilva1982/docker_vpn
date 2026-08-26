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

## Binding global constraints

- Nunca incluir ou imprimir chaves privadas. A configuração do servidor é `artifacts/wg-server.conf`; os arquivos `artifacts/wg-client-*.conf` devem manter segredo.
- O host precisa ter suporte de kernel WireGuard e liberar UDP 51820 no firewall/NAT.
- A validação `wg-quick strip` não pode ativar ou criar a interface `wg0`.
- Não há repositório Git: não crie commits nem tente criar um worktree.
- Use Serena MCP e Context7. Antes de editar, leia as instruções Serena, ative `/home/severo/Documents/projetos/paulo/vpn/wireguard` e consulte Context7 sobre os comandos Docker Compose de validação e operação usados na documentação.
