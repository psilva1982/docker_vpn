# Servidor WireGuard em Docker Compose

## Objetivo

Executar o servidor descrito em `artifacts/wg-server.conf` em um contêiner Docker, expondo a porta UDP 51820 do host e preservando a configuração como um artefato somente leitura.

## Decisão

Usar uma imagem Alpine construída localmente. Ela instala `wireguard-tools`, `iproute2` e `iptables`; o processo principal eleva a interface `wg0` com `wg-quick` e a derruba ao receber encerramento.

O Compose remove todas as capabilities padrão e concede somente `NET_ADMIN` e
`DAC_OVERRIDE`. `NET_ADMIN` configura a interface; `DAC_OVERRIDE` permite ao
processo ler o bind mount `0600`. O Compose define os encaminhamentos IPv4 e
IPv6 necessários no namespace de rede do contêiner, publica `51820/udp` e
monta `./artifacts/wg-server.conf` em `/etc/wireguard/wg0.conf` com acesso de
leitura. `DAC_OVERRIDE` pode ignorar checagens DAC tanto de leitura quanto de
escrita; neste serviço, o bind mount permanece `:ro` e nenhum outro caminho do
host é montado, mitigando a exposição sem eliminar essa capacidade.

Essa alternativa evita copiar chaves privadas para a imagem e mantém a configuração que já existe no repositório como fonte de verdade. O kernel do host deve ter suporte a WireGuard; o contêiner fornece as ferramentas de espaço de usuário, não o módulo do kernel.

## Artefatos

- `Dockerfile`: imagem mínima e comando de ciclo de vida da interface.
- `compose.yaml`: serviço `wireguard`, build local, permissão, sysctls, porta, volume e reinicialização.
- `README.md`: pré-requisitos, inicialização, parada, validação e ressalvas de segurança.

Os arquivos em `artifacts/` permanecem sem modificação. `wg-server.conf` será usado pelo servidor. Os três arquivos de cliente não serão montados no serviço e conservam o placeholder `Endpoint = <IP_SERVIDOR>:51820`, que deve ser substituído pelo endereço público/DNS do host antes de distribuí-los.

## Validação

1. `docker compose config` valida e renderiza o Compose.
2. A imagem é construída com `docker compose build`.
3. Um contêiner de validação executa `wg-quick strip /etc/wireguard/wg0.conf`, confirmando que o formato do arquivo do servidor é aceito sem ativar a interface.

Se Docker ou o suporte de kernel não estiver disponível no ambiente, será registrado como limitação de execução; a validação estática ainda será feita.

## Alternativas descartadas

- Imagem pronta de terceiros: reduz manutenção inicial, mas adiciona convenções próprias de variáveis e geração de configurações que não são necessárias para os arquivos existentes.
- `network_mode: host`: simplifica o roteamento, mas reduz isolamento e cria dependência mais forte do host. O mapeamento explícito da porta preserva uma configuração mais portátil.
