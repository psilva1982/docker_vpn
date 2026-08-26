# Task 3 fix round 1 review package

## Findings under review

1. Raw `wg-quick strip` could print `PrivateKey`; documentation must prevent secrets reaching the terminal.
2. `Address` is removed by `wg-quick strip`; it must be checked separately and sanitized.

## Amended README excerpt

```markdown
Confira a diretiva `Address` diretamente no arquivo montado, removendo campos
secretos antes de exibir qualquer resultado:

```sh
docker compose run --rm --no-deps --entrypoint /bin/sh wireguard -c 'sed -E "/^[[:space:]]*(PrivateKey|PresharedKey)[[:space:]]*=/d" /etc/wireguard/wg0.conf | grep -E "^[[:space:]]*Address[[:space:]]*="'
```

Para verificar o parse da configuração do servidor sem criar ou ativar a
interface `wg0`, use `wg-quick strip` e filtre os campos secretos antes de
exibir a saída. O resultado sanitizado deve conter `ListenPort` e três blocos
de peer; o comando não deve executar `wg-quick up` nem criar a interface:

```sh
docker compose run --rm --no-deps --entrypoint /usr/bin/wg-quick wireguard strip /etc/wireguard/wg0.conf | sed -E '/^[[:space:]]*(PrivateKey|PresharedKey)[[:space:]]*=/d'
```
```
