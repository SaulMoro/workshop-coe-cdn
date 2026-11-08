# check-on-stop

Hook `Stop`: cuando el agente termina, comprueba el vault con `tools/verify.sh`.

- **Qué hace.** Si el repositorio tiene `tools/verify.sh`, lo ejecuta. Si verify da errores, sale con 2 y escribe los errores en stderr: el cliente se los devuelve al agente, que sigue trabajando para corregirlos. Si verify pasa, sale con 0. Los avisos no bloquean.
- **Un solo reintento.** Si verify vuelve a fallar con los mismos cambios, o si el cliente indica `"stop_hook_active": true`, sale con 0 y el agente termina. Así nunca entra en bucle.
- **Qué lee.** El JSON del evento por stdin, `tools/verify.sh` y el estado de git (`git diff HEAD` y `git status --porcelain`).
- **Qué escribe.** Solo `.git/check-on-stop.last`, con la huella de los cambios del último fallo. Se borra cuando verify pasa.
- **Red.** Ninguna.
- **Fuera de un vault.** Sin `tools/verify.sh`, no hace nada y sale con 0.

Declaración exportada: `check-on-stop.json` llama a `bash .agents/hooks/check-on-stop.sh`, la ruta que crea el export. En el propio vault, `.github/hooks/check-on-stop.json` llama al script desde `asset-sets/`.
