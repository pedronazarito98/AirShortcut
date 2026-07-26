# Validação da integração Tico + release readiness

**Data**: 2026-07-26

**Branch**: `feat/consolidar-tico-release-readiness`

## Escopo consolidado

- identidade pública, recursos visuais e artefatos de distribuição usam `Tico`;
- produto SwiftPM, executável, bundle identifier, dados e preferências mantêm
  a compatibilidade técnica do AirShortcut;
- gates de build, testes, segurança, package, preflight e evidência física
  continuam separados para não produzir alegações indevidas.

## Resolução de sobreposição

- `README.md` foi mesclado automaticamente e ajustado para `dist/Tico.zip`;
- `outputs/qa-checklist.md` preserva a matriz rigorosa de release readiness e
  inclui os checks de identidade e upgrade do Tico;
- `outputs/signing-and-distribution.md` preserva os gates Developer ID e
  documenta a continuidade de TCC e dados;
- `script/ci_verify.sh` e `script/release_preflight.sh` validam `Tico.app` e
  `Tico.zip`, mas exigem `AirShortcut` como executável e
  `com.pedronazarito.AirShortcut` como bundle identifier.

## Evidência automatizada

| Verificação | Resultado |
| --- | --- |
| Sintaxe dos scripts shell | PASS |
| `git diff --check` | PASS |
| Build SwiftPM debug | PASS |
| Suite Swift | 111 executados, 0 falhas |
| `SecurityRegressionTests` | 8 executados, 0 falhas |
| Package ad hoc `dist/Tico.zip` | PASS |
| App extraído `Tico.app` | assinatura strict/deep PASS |
| Nome público | `Tico` |
| Executável técnico | `AirShortcut` |
| Bundle identifier | `com.pedronazarito.AirShortcut` |
| Build SwiftPM release | PASS |
| Preflight do release candidate | PASS ad hoc/development |
| Relatório físico sanitizado | estrutura e sanitização PASS |

## Limites preservados

- Nenhuma sessão física nova de trackpad foi executada.
- Nenhuma identidade Developer ID válida está instalada.
- Notarização, staple, Gatekeeper e máquina limpa permanecem `NOT-RUN`.
- O ZIP atual é um release candidate local e não deve ser apresentado como
  distribuição pública notarizada.
