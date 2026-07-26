# AirShortcut — validação de distribuição

**Data**: 2026-07-26  
**Resultado**: `not-attempted`  
**Blocker**: nenhuma identidade válida de codesign/Developer ID Application
está disponível neste ambiente (`security find-identity -p codesigning -v`
retornou `0 valid identities found`).

## Gates Developer ID

| Gate obrigatório | Estado | Evidência/observação |
| --- | --- | --- |
| Identidade Developer ID Application | BLOCKED | nenhuma identidade válida disponível |
| Assinatura do app e código aninhado | NOT-RUN | não existe artefato Developer ID |
| Hardened Runtime | NOT-RUN | não existe artefato Developer ID |
| `codesign --verify --deep --strict` | NOT-RUN | não existe artefato Developer ID; o dry-run ad hoc está documentado separadamente |
| Notarização aceita pelo `notarytool` | `not-attempted` | sem identidade e sem credenciais fornecidas pelo proprietário |
| Staple do ticket | `not-attempted` | depende de notarização aceita |
| `stapler validate` | NOT-RUN | nenhum ticket foi anexado |
| `spctl -a -vv` | NOT-RUN | não existe artefato de distribuição |
| Execução em máquina/usuário limpo | NOT-RUN | não existe artefato de distribuição |

## Decisão

A distribuição pública assinada e notarizada está **BLOCKED**. O ZIP ad hoc
validado em `outputs/release-dry-run-2026-07-26.md` continua sendo apenas um
dry-run local e não satisfaz nenhum dos gates Developer ID acima.

Quando o proprietário disponibilizar a identidade e operar as credenciais
Apple fora do repositório, a validação deve:

1. gerar um artefato Developer ID com Hardened Runtime;
2. verificar o app e todo código aninhado;
3. submeter o ZIP e preservar o submission ID e a aceitação do `notarytool`;
4. anexar e validar o ticket com `stapler`;
5. executar `spctl` e abrir o mesmo artefato em máquina ou usuário limpo;
6. publicar somente logs sanitizados associados ao SHA-256 do ZIP.

Nenhuma credencial, perfil, token, caminho pessoal ou saída privada de
Keychain foi registrada neste relatório.
