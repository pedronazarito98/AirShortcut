# AirShortcut Release Readiness — author execution freeze

**Frozen on**: 2026-07-26

**Baseline**: `27e0650`

**Implementation range reviewed by the author**: `27e0650..326cc07`

**Verifier input**: baseline acima até o commit T19 que adiciona este arquivo e
congela `spec.md`, `design.md`, `tasks.md` e `context.md`.

Os quatro documentos de origem foram incluídos sem reescrita pelo worker do
Batch 3. O Verifier deve tratá-los como fonte de verdade e não herdar as
conclusões deste relatório.

## Tarefas do Batch 3

| Task | Commit | Resultado |
| --- | --- | --- |
| T13 | `fff062f` | preflight separado; ZIP extraído passa strict/deep; modo ad hoc explícito |
| T14 | `44ed574` | template de metadados/evidência com gates de notarização |
| T15 | `c4073c3` | dry-run ad hoc sanitizado e revisão de assinatura |
| correção de gate | `10b2002` | array SwiftPM vazio compatível com `set -u` no Bash do macOS |
| T16 | `b90929f` | Developer ID/notarização `not-attempted`; blocker explícito |
| T17 | `1b7785c` | decisão `PREVIEW`; distribuição e suporte físico `BLOCKED` |
| T18 | `9f80d33` | release notes e issues locais com critérios de aceite |
| correção de gate | `b0ddf45` | trailing whitespace removido das evidências |
| correção pós-Verifier | `326cc07` | script canônico e estado de lessons restaurados; gaps reais registrados como candidatos |
| correção pós-segunda verificação | `24d6f4d` | máscara permitida do fallback testada integralmente; M1 com `.mouseMoved` morto em scratch |

## Gates finais do autor

| Gate | Resultado |
| --- | --- |
| `./script/ci_verify.sh --package` | PASS |
| Swift tests executados | 100, 0 failures |
| `SecurityRegressionTests` | 8, 0 failures |
| Package ZIP extraído | `codesign --verify --deep --strict`: PASS |
| Preflight | `ad-hoc/development`; Hardened Runtime não confirmado; entitlements ausentes |
| Hardware report validator | PASS estrutural/sanitização |
| `git diff --check` | PASS após `b0ddf45` |

Contagem estática de métodos XCTest:

- baseline `27e0650`: 97;
- freeze do autor: 100;
- variação: +3; nenhuma redução observada.

## Revisão de escopo

O range altera somente CI/gates, documentação pública, evidência sanitizada,
testes de replay/permissão/fallback, correção limitada do serviço necessária
às regressões, scripts de QA/release e os artefatos desta iniciativa.
`dist/AirShortcut.zip` e `dist/AirShortcut.app` permanecem artefatos locais
fora do commit.

## Blockers e limites preservados

- `LICENSE`: BLOCKED até decisão explícita do proprietário.
- Physical-support/UAT: NOT-RUN; não há PASS inferido de replay ou unit tests.
- Magic Trackpad, sleep/wake, reconexão e false-positive observation: NOT-RUN.
- Developer ID: BLOCKED; `security find-identity` encontrou 0 identidades
  válidas.
- Notarização: `not-attempted`; sem evidência `notarytool`.
- Staple, `stapler validate`, `spctl` e máquina limpa: NOT-RUN.
- Workflow remoto do GitHub Actions: ainda requer evidência de execução real.
- `scripts/lessons.py`: restaurado a partir do asset canônico do
  `tlc-spec-driven`; quatro gaps reais foram registrados sem promover guidance
  antes de recorrência em outra feature.
- Segunda verificação: o mutante M1 expôs uma denylist parcial no teste do
  fallback. A correção compara a máscara completa permitida e `L-005` registra
  o sinal `surviving_mutant` ancorado no relatório.

## Handoff independente

O orquestrador deve fornecer ao Verifier fresco:

1. `spec.md`, `design.md`, `tasks.md` e `context.md`;
2. o range desde `27e0650` até o commit T19;
3. testes e relatórios referenciados no checklist;
4. o contrato de evidence-or-zero e sensor de mutação em scratch.

O worker autor não executou o Verifier e não criou `validation.md`.
