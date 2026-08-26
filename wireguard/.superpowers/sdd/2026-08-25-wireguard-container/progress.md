# SDD ledger — plan: docs/superpowers/plans/2026-08-25-wireguard-container.md

## Execution environment

Ruling: Execute in the current workspace — this directory is not a Git repository, so a Git worktree and commit-based review packages cannot be created. This costs Git isolation and commit-range diffs; task reviews will instead use the exact changed files and validation output.

## Pre-flight scan

| Tasks | Produced / consumed interface | Finding |
| --- | --- | --- |
| Task 1 → Task 2 | `Dockerfile` produces the local image consumed by `compose.yaml` through `build.context: .` | Compatible; both use the workspace root and the `wireguard` service. |
| Task 2 → Task 3 | `compose.yaml` mounts `artifacts/wg-server.conf` at `/etc/wireguard/wg0.conf`; README invokes that exact path with `wg-quick strip` | Compatible; validation is non-intrusive and does not create `wg0`. |
| Task 1 | Dockerfile dependencies and lifecycle command | Internally consistent; `wg-quick` is supplied by `wireguard-tools`. |
| Task 2 | Port, capability, sysctls and read-only volume | Internally consistent; the values match the spec. |
| Task 3 | Documentation and validation command | Internally consistent; commands use the service and path created by Task 2. |

Task 1: minor (deferred): Docker build could not run because Compose is not yet present and direct Docker access is sandbox-blocked; repeat after Task 2 in a Docker-capable environment.

Task 1: complete (no commits; review clean)

Task 2: complete (no commits; review clean)

Task 3: Ruling: substituir a exibição bruta de `wg-quick strip` por uma tubulação que remove `PrivateKey` e `PresharedKey`, e verificar `Address` estaticamente no arquivo fonte — o plano exigia o comando bruto, mas isso conflita com a restrição superior de nunca imprimir chaves privadas. Custo se errado: a validação pode perder uma diretiva, mitigado por checagem estática explícita.
Task 3: fix round 1/5 (2 findings open: saída de segredo e critério incorreto de Address)
Task 3: fix round 1/5 (2 findings addressed, 1 open — pipeline sem pipefail pode mascarar falha)
Task 3: Ruling: usar arquivos temporários no contêiner com encadeamento `&&` para sanitizar a saída sem mascarar o status de `wg-quick strip`. Custo se errado: arquivo temporário contém segredo somente no contêiner efêmero `--rm`; ele não é montado nem enviado ao terminal.
Task 3: fix round 2/5 (1 finding open: preservar status da validação)
Task 3: fix round 2/5 (1 addressed, 0 open; review clean)
Task 3: complete (no commits; review clean)

Final review: Critical — `artifacts/*.conf` com 0644; Important — falta `.dockerignore`, capabilities padrão remanescentes e estado de validação dinâmico otimista; Minor — comando consolidado não afirma Address/ListenPort/peers.
Ruling: usuário autorizou `chmod 0600 artifacts/*.conf` e uma correção final única para resolver todos os achados. Custo se errado: usuários não proprietários deixam de ler as configurações, que é o comportamento de segurança pretendido.
Ruling: usuário autorizou adicionar `DAC_OVERRIDE` junto de `NET_ADMIN`, pois o contêiner precisa ler o bind mount `0600` sem restaurar capabilities padrão. Custo se errado: a capability adicional ignora permissões DAC dentro do contêiner, mitigada por não montar outros caminhos do host e por manter `wg0.conf` read-only.
Final DAC review: Important — README e spec descrevem incorretamente `DAC_OVERRIDE` como sem efeito de escrita; report de evidência ausente. Ruling: corrigir a documentação para reconhecer bypass DAC de leitura e escrita, deixando claro que o bind mount `:ro` impede escrita nele; criar o relatório exigido. Custo se errado: subestimaria o privilégio no modelo de ameaça.
