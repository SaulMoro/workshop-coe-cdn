# workshop-coe-cdn

CDN de práctica de los talleres del AI CoE. Publica como paquetes de [APM](https://microsoft.github.io/apm/) las líneas de dependencia de [workshop-coe-vault](https://github.com/SaulMoro/workshop-coe-vault). Es material de formación: no lo instales en proyectos reales.

## Instalar

Necesitas apm 0.35 o posterior (`apm --version`). Registra el marketplace con el nombre `cdn-taller`, que es el que usan los talleres:

```bash
apm marketplace add saulmoro/workshop-coe-cdn --name cdn-taller
apm marketplace browse cdn-taller
```

Declara en `apm.yml` el paquete y el rango que sigues, y ejecuta `apm install`:

```yaml
name: mi-proyecto
version: 1.0.0
targets:
  - copilot
dependencies:
  apm:
    - git: https://github.com/saulmoro/workshop-coe-cdn
      path: packages/front-react
      ref: "^1.0.0"
```

Es lo que escribe `apm install 'front-react@cdn-taller' --target copilot`. La dirección va en minúsculas, como la anota apm en el lock: con otra grafía, `apm deps list` de apm 0.35 da los paquetes por huérfanos.

## Paquetes

| Paquete | Línea de dependencia del vault | Trae | Depende de |
|---|---|---|---|
| `front-react` | front-react, front-core, dev-typescript y dev-core | skills `react-best-practices`, `react-forms`, `react-check`, `commit-messages` · instructions `react-components`, `front-styles`, `ts-strict`, `dev-tests` · agent `react-reviewer` | `common` |
| `dev-typescript` | dev-typescript y dev-core | skills `typescript-best-practices`, `commit-messages` · instructions `ts-strict`, `dev-tests` | `common` |
| `asset-kit` | asset-kit | skill `asset-review` · hook `check-on-stop` | `common` |
| `common` | common-core | skills `clarify-task`, `project-glossary` | — |

`common` no aparece en el marketplace: llega como dependencia de los demás. Cada paquete lleva su línea de dependencia entera menos lo que ya trae `common`. Instala una sola línea por repositorio: `front-react` ya incluye todo `dev-typescript`.

## Versiones

Cada paquete tiene su versión y su etiqueta, `<paquete>--v<versión>`, como `front-react--v1.1.0`. Su `CHANGELOG.md` dice qué cambió y desde qué commit del vault.

- **major**: quita o renombra una pieza. Un rango `^1.0.0` no la toma.
- **minor**: añade una pieza o una regla.
- **patch**: corrige sin cambiar lo que pide.

`git tag --list` da las versiones publicadas, y `git show <etiqueta>:packaging.json` el commit del vault del que salió cada una. En este repositorio no hay etiquetas `v*`: apm las tendría en cuenta para todos los paquetes a la vez.

## Cómo se construye

`packaging.json` fija un commit del vault. `tools/package.sh` lee el vault en ese commit con `git archive`, exporta cada línea con el `tools/export.sh` de ese mismo commit, quita a cada paquete lo que ya trae `common` y escribe `packages/` y `.claude-plugin/marketplace.json`. Nada de `packages/` se edita a mano.

```bash
git clone https://github.com/SaulMoro/workshop-coe-vault.git ../workshop-coe-vault
tools/package.sh --vault ../workshop-coe-vault --check   # lo versionado es lo que sale del vault fijado
tools/check.sh                                          # etiquetas, nombres, marketplace y texto oculto
```

El workflow `check` hace lo mismo en cada push y en cada etiqueta. Para empaquetar otro commit o publicar una versión, lee [docs/mantener.md](docs/mantener.md).

Requisitos de las herramientas: bash, git, python3 y node (lo usa el `export.sh` del vault).

## Licencia

[MIT](LICENSE).
