# AirShortcut — template de evidência de release

> Preencha a partir do artefato que será publicado. Não use este documento
> para promover um dry-run ad hoc a release distribuível.

## Identificação

| Campo | Valor |
| --- | --- |
| Versão (`CFBundleShortVersionString`) | `<versão>` |
| Build (`CFBundleVersion`) | `<build>` |
| Commit SHA completo | `<sha>` |
| macOS mínimo (`LSMinimumSystemVersion`) | `<versão>` |
| Artefato verificável | `<nome-do-zip>` |
| SHA-256 do artefato | `<sha256>` |

O commit deve existir no repositório e o SHA-256 deve ser calculado sobre o
mesmo ZIP disponibilizado aos usuários.

## Assinatura e confiança

| Campo | Valores permitidos | Valor |
| --- | --- | --- |
| Signing mode | `ad-hoc/development` ou `developer-id` | `<modo>` |
| Identidade | `ad hoc` ou nome público do certificado Developer ID | `<identidade>` |
| Hardened Runtime | `enabled`, `not-confirmed` | `<estado>` |
| Notarization | `not-attempted`, `rejected`, `accepted` | `<estado>` |
| Notarytool submission ID | ID não secreto ou `n/a` | `<id>` |
| Staple | `not-attempted`, `failed`, `validated` | `<estado>` |
| Clean-machine execution | `not-run`, `failed`, `passed` | `<estado>` |

Regras:

- `ad-hoc/development` nunca significa aceitação do Gatekeeper ou notarização.
- `notarization: accepted` exige a saída de aceitação do `notarytool` para
  este SHA-256 e o respectivo submission ID.
- Uma distribuição aprovada também exige Developer ID, Hardened Runtime,
  assinatura válida do código aninhado, `stapler validate` e execução em
  máquina ou usuário limpo.
- Credenciais Apple, perfis, tokens, nomes de usuário e caminhos pessoais não
  entram neste documento nem no repositório.

## Evidência

| Verificação | Comando/evidência sanitizada | Resultado |
| --- | --- | --- |
| Bundle e código aninhado | `codesign --verify --deep --strict AirShortcut.app` | `<PASS/FAIL>` |
| Detalhes e entitlements | `codesign -dvvv --entitlements :- AirShortcut.app` | `<resumo>` |
| Gatekeeper | `spctl -a -vv AirShortcut.app` | `<PASS/FAIL/NOT-RUN>` |
| Notarização | log de aceitação associado ao submission ID | `<PASS/FAIL/NOT-RUN>` |
| Staple | `stapler validate AirShortcut.app` | `<PASS/FAIL/NOT-RUN>` |
| Máquina limpa | classe do ambiente e resultado, sem dados pessoais | `<PASS/FAIL/NOT-RUN>` |

## Limitações e status

- Status público: `<technical-preview/blocked/ready>`.
- Captura avançada: usa framework privado da Apple e deve ser revalidada por
  versão do macOS.
- Captura pública de fallback: `<estado e evidência>`.
- Cobertura física: `<relatório sanitizado ou NOT-RUN>`.
- Limitações conhecidas: `<lista objetiva>`.

## Release notes

Resumo da mudança:

`<mudança e impacto observável>`

Como verificar:

`<passos reproduzíveis ligados ao commit e ao artefato acima>`
