# Correção autorizada — acesso ao bind mount WireGuard

O usuário autorizou explicitamente adicionar `DAC_OVERRIDE` além de `NET_ADMIN`. Corrija a regressão sem criar subagentes, sem commits e sem ler conteúdos de `artifacts/`.

## Implementação

1. Em `compose.yaml`, mantenha `cap_drop: [ALL]` e configure `cap_add` com exatamente `NET_ADMIN` e `DAC_OVERRIDE`.
2. Atualize `README.md`: explique de forma concisa que `DAC_OVERRIDE` é necessária para o processo no contêiner ler o bind mount `0600`; ela não concede escrita porque o volume é `:ro` e nenhum outro caminho do host é montado.
3. Atualize a especificação e o plano para substituir a afirmação de “somente NET_ADMIN” por “NET_ADMIN e DAC_OVERRIDE”, registrando a justificativa de leitura do arquivo `0600`.
4. Acrescente o estado dessa correção a `final-fix-report.md`.

## Validação

- Rode `docker compose config` e confirme `cap_drop: ALL`, exatamente `NET_ADMIN` e `DAC_OVERRIDE` em `cap_add`, UDP 51820, sysctls e o volume read-only.
- Use comandos que exibam somente os modos de `artifacts/*.conf` (devem permanecer 0600); nunca imprima seus conteúdos.
- Não execute `docker compose up` nem a validação dinâmica caso o ambiente não permita namespaces; mantenha-a marcada como pendente.

## Constraints

- Use Serena MCP (instruções e ativação) e Context7 (Compose capabilities) antes de editar.
- Não modifique conteúdos dos artefatos, não revele chaves e não use capabilities adicionais.
- Escreva relatório em `.superpowers/sdd/2026-08-25-wireguard-container/dac-override-fix-report.md`.
