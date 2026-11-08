# Mantener el CDN

## Empaquetar un commit del vault

1. Clona el vault y trae el commit: `git clone https://github.com/SaulMoro/workshop-coe-vault.git ../workshop-coe-vault && git -C ../workshop-coe-vault fetch origin <sha>`.
2. Cambia `vault.commit` en `packaging.json` por el SHA completo. Es la única línea que cambia a mano.
3. `tools/package.sh --vault ../workshop-coe-vault`. Lee la auditoría de cada línea (la ruta sale al final) y el `git diff`. Si cambia algo que se ejecuta (hooks, scripts), léelo entero antes de seguir.
4. `tools/check.sh` y commit: «Empaqueta el vault en <sha corto>».

No edites nada de `packages/` a mano: el siguiente empaquetado lo pisa. Los cambios van al vault, con un PR.

## Publicar una versión

1. En cada paquete que cambió, sube `version:` en su `apm.yml` según el README y añade arriba de su `CHANGELOG.md` la sección nueva (`## <versión>`), con el commit del vault.
2. Un commit, «Publica <paquete> <versión>», y una etiqueta anotada por paquete: `git tag -a <paquete>--v<versión> -m "<paquete> <versión> (vault <sha corto>)"`.
3. `tools/package.sh --vault ../workshop-coe-vault --check`, `tools/check.sh` y `git push --atomic --follow-tags origin main`.

`package.sh` conserva `version:`, los `ref:` ya escritos y `CHANGELOG.md`: son de la publicación, no del vault.

Una etiqueta publicada no se mueve ni se borra: los `apm.lock.yaml` de quien instaló guardan su commit. Un error se arregla con otra versión. No crees nunca etiquetas `v*` ni `x.y.z` a secas: apm las tendría en cuenta para todos los paquetes del repositorio.

## Antes de cada push

`tools/check.sh --denylist <fichero>` comprueba además que ninguna línea del fichero aparece en el árbol ni en el historial. Ese fichero vive fuera del repositorio.
