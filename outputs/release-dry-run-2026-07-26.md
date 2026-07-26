# AirShortcut — dry-run ad hoc de empacotamento

**Data**: 2026-07-26  
**Classificação**: desenvolvimento/dry-run ad hoc  
**Não é**: release distribuível, artefato Developer ID ou artefato notarizado

## Identificação

| Campo | Evidência |
| --- | --- |
| Versão | `0.1.0` |
| Build | `1` |
| Commit inspecionado | `44ed574fed1b02a27b417aae1c370894d0018d5c` |
| Bundle ID | `com.pedronazarito.AirShortcut` |
| macOS mínimo | `14.0` |
| Arquitetura | `arm64` |
| Artefato local | `dist/AirShortcut.zip` |
| SHA-256 do ZIP | `0823f2ddadbeeda3e8c3557041be8f519337a81448c004ba2f1e93d41eccfbe7` |

O ZIP é um resultado local reproduzível e permanece fora do Git. O hash acima
identifica apenas esta execução; um novo build pode produzir outro hash.

## Revisão de assinatura

| Verificação | Resultado observado |
| --- | --- |
| Extração em diretório temporário limpo | PASS |
| `codesign --verify --deep --strict` no app extraído | PASS |
| Identidade | `Signature=adhoc`; sem Team Identifier |
| Código aninhado | verificado pelo modo `--deep`; nenhum helper/framework aninhado presente no bundle |
| Hardened Runtime | não confirmado; flags `adhoc`, sem `runtime` |
| Entitlements | nenhum entitlement declarado |
| Notarização | `not-attempted`; nenhuma aceitação do `notarytool` foi produzida ou inspecionada |
| Staple | `not-validated` |
| Gatekeeper/máquina limpa | `NOT-RUN` |

## Comandos reproduzíveis

```bash
AIRSHORTCUT_DISABLE_SWIFTPM_SANDBOX=1 ./script/build_and_run.sh --package
./script/release_preflight.sh dist/AirShortcut.zip
```

O preflight também extrai o ZIP em `/private/tmp`, remove atributos estendidos
da cópia temporária e executa verificação estrita sem abrir a aplicação.

## Decisão

**PASS apenas para dry-run local ad hoc.** Este artefato não pode ser descrito
como aceito pelo Gatekeeper ou notarizado. Uma distribuição exige Developer
ID, Hardened Runtime, assinatura de código aninhado, aceitação do `notarytool`,
staple validado e execução em máquina ou usuário limpo.

O relatório não contém credenciais, nomes de usuário, caminhos pessoais,
serial de hardware, dump de TCC ou frames de trackpad.
