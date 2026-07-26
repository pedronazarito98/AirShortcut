# AirShortcut — decisão de release readiness

**Data da avaliação**: 2026-07-26

**Status geral**: `PREVIEW`

**Distribuição Developer ID**: `BLOCKED`

**Suporte físico de trackpad**: `BLOCKED` (`NOT-RUN`)

`PREVIEW` autoriza apenas publicar o código como technical preview para
desenvolvimento e avaliação. Não autoriza chamar o app de stable, distribuir
o ZIP ad hoc como release para usuários, nem declarar suporte físico.

## Regra objetiva de status

- `READY`: todos os P1 estão PASS, não há evidência física obrigatória
  `FAIL/NOT-RUN`, existe licença decidida pelo proprietário e o mesmo artefato
  passou Developer ID, notarização, staple e máquina limpa.
- `PREVIEW`: gates automatizados estão verdes e as limitações estão
  documentadas, mas um ou mais gates manuais, legais ou de distribuição estão
  `BLOCKED/NOT-RUN`. Somente código/dry-run de desenvolvimento pode ser
  apresentado.
- `BLOCKED`: há falha automatizada/de segurança, documentação faz alegação
  não sustentada, ou o alvo pretendido é distribuição/suporte físico sem os
  gates obrigatórios.

Aplicação da regra: a baseline automatizada passou, mas licença, hardware
físico e distribuição Developer ID permanecem bloqueados. Portanto o escopo
geral é `PREVIEW`; os dois subescopos de release binária e suporte físico são
`BLOCKED`.

## Mapa P1 — RR-01 a RR-14

| Req. | Gate | Estado | Evidência ou blocker |
| --- | --- | --- | --- |
| RR-01 | CI macOS falha em build/test/shell/package | BLOCKED | `.github/workflows/ci.yml` e `script/ci_verify.sh` passam localmente, mas não há run remoto nem PR controlado vermelho; configuração não substitui execução. |
| RR-02 | Gate local equivalente e contagem | PASS | `./script/ci_verify.sh --package`: 100 testes, ZIP ad hoc verificado e paths reportados. |
| RR-03 | Resumo não infere hardware | BLOCKED | o YAML contém o texto correto, mas não há summary de um job remoto bem-sucedido para servir como evidência. |
| RR-04 | Atalho `⌘6` sem contradição | PASS | `README.md`; `outputs/qa-checklist.md`. |
| RR-05 | Licença, status e private API | BLOCKED | status/private API estão no `README.md`; `LICENSE` aguarda decisão do proprietário e não foi inventada. |
| RR-06 | Reporte privado de segurança | PASS | `SECURITY.md`. |
| RR-07 | Matriz física sanitizada completa | NOT-RUN | `outputs/hardware-validation/report-2026-07-26.md`; estrutura validada, mas não houve sessão física. |
| RR-08 | Permissão/fallback e segurança de input | PARTIAL | regressões automatizadas passam; UAT físico permanece NOT-RUN no relatório de hardware. |
| RR-09 | Replay 0.5×/1×/2× sem ações | PASS automatizado | testes SwiftPM e linhas de replay no relatório: progresso final/estado aceito com action log inalterado. |
| RR-10 | Ausência física impede PASS | BLOCKED corretamente | tap, hold, swipes, pinch, rotação, sleep/wake, reconexão, fallback, falso positivo e Magic Trackpad estão NOT-RUN. |
| RR-11 | App/ZIP extraído com assinatura estrita | PASS ad hoc | `outputs/release-dry-run-2026-07-26.md`; `script/release_preflight.sh`. |
| RR-12 | Ausência de Developer ID é ad hoc | PASS | preflight e dry-run classificam `ad-hoc/development` sem alegar Gatekeeper/notarização. |
| RR-13 | Checklist exige Developer ID + notarização + máquina limpa | PASS contratual | `outputs/release-validation-2026-07-26.md` exige todos os gates e mantém a execução real BLOCKED: 0 identidades válidas, notarização `not-attempted` e demais gates NOT-RUN. |
| RR-14 | Metadados e evidência de release publicado | BLOCKED | `outputs/release-template.md` define o contrato; não existe artefato publicável Developer ID nem release final preenchido. |

## Fechamento independente — RR-15 a RR-18

| Req. | Estado | Evidência ou blocker |
| --- | --- | --- |
| RR-15 | PASS | `.specs/features/release-readiness/validation.md` mapeia cada AC a evidência ou gap. |
| RR-16 | PASS | três mutações comportamentais em scratch foram mortas; nenhuma sobreviveu. |
| RR-17 | PASS | `scripts/lessons.py` registrou quatro lessons candidatas ancoradas nos gaps reais. |
| RR-18 | PASS | o veredito permanece BLOCKED enquanto requisitos obrigatórios não têm evidência. |

## Gates por área

| Área | Decisão | Fonte |
| --- | --- | --- |
| Automatizado | PASS local | 100 testes, 8 regressões focadas, package ad hoc estrito |
| Segurança | PASS da baseline automatizada | `SECURITY.md` e suite `SecurityRegressionTests` |
| Documentação | PARTIAL | coerente para preview; licença segue BLOCKED |
| Hardware físico | BLOCKED / NOT-RUN | relatório sanitizado de 2026-07-26 |
| Packaging ad hoc | PASS para dry-run | relatório de dry-run e preflight |
| Distribuição | BLOCKED | sem Developer ID, notarytool acceptance, staple ou máquina limpa |

## Blockers para sair de `PREVIEW`

1. Decisão explícita do proprietário sobre a licença e inclusão de `LICENSE`.
2. Sessão física completa em trackpad interno e Magic Trackpad, incluindo
   permission denied, fallback, sleep/wake, reconexão e falsos positivos.
3. Artefato Developer ID com Hardened Runtime, nested signing, aceitação do
   `notarytool`, staple validado, `spctl` e execução em máquina/usuário limpo.
4. Execução remota do workflow em PR, incluindo um teste controlado vermelho e
   um run limpo cujo summary preserve o limite entre automação e hardware.

Os documentos apontados são sanitizados. Logs brutos, credenciais, TCC,
serial de hardware, frames de contato e caminhos pessoais não devem ser
incorporados a este checklist.
