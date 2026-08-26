# Correção final — servidor WireGuard em Docker Compose

O usuário autorizou explicitamente alterar as permissões dos arquivos em `artifacts/` para corrigir a revisão final de segurança. Implemente todos os itens abaixo, sem criar subagentes e sem fazer commit.

## Achados obrigatórios

1. Mudar o modo de `artifacts/wg-server.conf` e de cada `artifacts/wg-client-*.conf` para `0600`. Não alterar seus conteúdos nem imprimir chaves.
2. Criar `.dockerignore` que exclua `artifacts/` do contexto de build. Não exclua `Dockerfile`, `compose.yaml` ou `README.md`.
3. Alterar `compose.yaml` para remover as capabilities padrão com `cap_drop: [ALL]` e adicionar somente `NET_ADMIN` com `cap_add`, mantendo todos os valores atuais (porta UDP 51820, volume read-only, sysctls e restart).
4. Atualizar `README.md` para incluir uma checagem segura de permissões que não imprime conteúdo de configuração e para declarar que a validação dinâmica de `wg-quick strip` está pendente quando o ambiente não permitir namespaces de rede. O comando consolidado deve confirmar, sem imprimir segredos, `Address`, `ListenPort` e exatamente três peers, além de preservar qualquer falha de `wg-quick strip`.
5. Atualizar o relatório de Task 3 para refletir a validação dinâmica pendente, sem alegar que ela passou.

## Validação

- Rode `docker compose config` e confirme que há `cap_drop: ALL`, `cap_add: NET_ADMIN`, somente `51820/udp`, os sysctls e a montagem read-only.
- Use `stat` ou `find -printf` apenas para os modos dos quatro arquivos em `artifacts/`; não leia nem exiba conteúdo.
- Faça uma checagem estática do README para confirmar que seus comandos não exibem `PrivateKey` nem `PresharedKey`.
- Se tentar a validação dinâmica, mantenha toda saída sanitizada e registre qualquer bloqueio externo.

## Constraints

- Use Serena MCP (instruções e ativação de projeto) e Context7 (Compose/Docker) antes de editar.
- Não iniciar a VPN, não executar `docker compose up`, não modificar conteúdos de `artifacts/` e não imprimir chaves.
- Escreva relatório em `.superpowers/sdd/2026-08-25-wireguard-container/final-fix-report.md` com arquivos alterados, permissões verificadas, validações e limitações.
