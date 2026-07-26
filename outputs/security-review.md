# Revisão de Segurança do AirShortcut

Data: 25/07/2026  
Scan: `41b26469-f170-4bb2-8b6a-b45ef25b5a43`  
Escopo: todos os arquivos elegíveis para o primeiro commit no Git

## Resultado

Do ponto de vista da segurança do código-fonte, o repositório está pronto para
receber o primeiro commit e ser publicado em um repositório privado ou público
no GitHub.

O scan inicial do Codex Security revisou 125 candidatos à publicação e relatou
27 achados: 3 de severidade média e 24 de severidade baixa. A árvore corrigida
contém 131 candidatos porque inclui a suíte específica de regressão de
segurança, esta revisão e as versões traduzidas dos artefatos técnicos. Não
foram encontradas chaves de API, senhas, tokens
de acesso, chaves privadas, certificados, caminhos pessoais do sistema de
arquivos ou arquivos de credenciais, nem no scan original nem na revisão final
dos candidatos à publicação.

Todos os 27 achados reportáveis foram corrigidos, e os caminhos de código
relevantes possuem cobertura de regressão direcionada. Uma preocupação
originalmente adiada na fronteira de callbacks privados do Multitouch também
foi reforçada preventivamente com uma barreira de drenagem dos callbacks em
andamento e um contexto de callback retido.

## Resumo das correções

| Fronteira | Achados corrigidos | Controle implementado |
| --- | ---: | --- |
| Importação e decodificação de documentos de regras | 14 | Limite de leitura de 8 MiB, política para coleções, textos e números, decodificação segura de intervalos, rejeição atômica, URLs limitadas a HTTP(S) e aritmética de prioridade protegida |
| Autoridade das automações importadas | 7 | Toda regra substituída, mesclada ou recém-importada entra desativada antes de chegar ao armazenamento ativo |
| Leitura, decodificação, agendamento e renderização de replays | 4 | Limites de bytes, frames, contatos, duração, textos e números; timestamps monotônicos; agendamento de um frame por vez; limites na gravação e no processamento |
| Autoridade e ciclo de vida do trackpad global | 1, além de 1 preocupação adiada | Verificação de Monitoramento de Entrada/Acessibilidade antes de iniciar o provedor, encerramento seguro em caso de falha, concessão e drenagem do callback C e contexto Swift retido |
| Preparação para compilação e execução | 1 | Diretório raiz exclusivo criado com `mktemp`, modo 0700, filhos separados para preparação, execução e verificação, além de validação estrita da assinatura antes da abertura |
| Exportação CSV | 1 | Prefixos interpretáveis como fórmulas por planilhas são neutralizados antes do escape CSV |

As contagens se sobrepõem quando os achados compartilham a mesma causa raiz: o
achado de URL participa tanto da validação do documento quanto da autoridade
importada. As 27 ocorrências únicas permanecem integralmente mapeadas abaixo.

## Situação dos achados

### Severidade média

- `as-b16-import-activation-001` — corrigido ao preparar as regras importadas
  desativadas.
- `as-trackpad-tcc-order-001` — corrigido pela verificação centralizada de
  permissões e pelo encerramento seguro do provedor.
- `as-b24-predictable-tmp-race-001` — corrigido com diretórios temporários
  exclusivos e verificação da cópia final executada.

### Severidade baixa: limites de documentos e do tempo de execução

- `as-b02-custom-samples-002`
- `as-b02-custom-tolerance-001`
- `as-b05-sequence-interval-001`
- `as-b13-step-delay-002`
- `as-b13-step-timeout-003`
- `as-b13-workflow-timeout-001`
- `as-b16-library-gesture-dos-002`
- `as-b20-step-editor-timeout-002`
- `as-b20-workflow-editor-timeout-001`
- `as-priority-overflow-001`
- `as-url-scheme-001`
- `as-workflow-decode-001`
- `airshortcut-trackpad-trigger-pressure-range-crash`

Esses achados foram corrigidos por `DocumentSecurityPolicy`, pela decodificação
segura de intervalos, pelas proteções nos pontos finais de workflow, pela soma
de prioridade sem estouro e pela lista permitida de esquemas de URL.

### Severidade baixa: recursos de replay

- `as-b11-replay-timestamp-001`
- `as-b19-replay-contacts-002`
- `as-replay-import-bounds-001`
- `airshortcut-replay-unbounded-touch-array-dos`

Esses achados foram corrigidos pelo contrato de replay limitado e pelo
agendador que mantém somente o próximo frame pendente.

### Severidade baixa: autoridade importada

- `airshortcut-imported-application-control-without-activation-consent`
- `airshortcut-imported-clipboard-write-without-activation-consent`
- `airshortcut-imported-keyboard-injection-without-activation-consent`
- `airshortcut-imported-macos-shortcut-without-activation-consent`
- `airshortcut-imported-open-url-without-activation-consent`
- `airshortcut-imported-window-control-without-activation-consent`

Esses achados foram corrigidos ao preparar todas as regras importadas
desativadas. Shell e AppleScript mantêm sua aprovação separada, vinculada ao
conteúdo exato.

### Severidade baixa: métricas exportadas

- `as-b13-metrics-csv-004` — corrigido pela neutralização de prefixos de
  fórmula.

## Evidências de verificação

| Etapa | Comando | Resultado |
| --- | --- | --- |
| Regressões de segurança direcionadas | `swift test --disable-sandbox --filter SecurityRegressionTests` | 8 aprovados, 0 falhas |
| Suíte completa do pacote | `swift test --disable-sandbox` | 97 aprovados, 0 falhas |
| Sintaxe do shell | `bash -n script/build_and_run.sh` | aprovado |
| Compilação e assinatura do pacote | `./script/build_and_run.sh --package` | aprovado |
| Assinatura da distribuição extraída | `codesign --verify --deep --strict --verbose=2 AirShortcut.app` | válida em disco e satisfaz o requisito designado |
| Higiene do Git | `git status --short --ignored` e `git ls-files -co --exclude-standard` | artefatos de compilação, SwiftPM, Codex e distribuição excluídos |
| Padrões de credenciais | varreduras somente nos candidatos, procurando chaves, tokens, chaves privadas, atribuições e caminhos | nenhuma credencial ou caminho pessoal encontrado |

A suíte de regressão demonstra que:

- documentos de regras malformados são rejeitados sem alterar regras em
  memória ou persistidas;
- documentos grandes demais são rejeitados antes da decodificação;
- intervalos de pressão invertidos falham de forma segura, sem encerrar o app;
- violações de URL, workflow e prioridade importadas não chegam ao estado
  ativo;
- a ausência de autorização para entrada global impede o início do provedor de
  trackpad;
- replays com contatos em excesso ou durações extremas são rejeitados;
- um replay legítimo e limitado continua fazendo ida e volta corretamente;
- URLs que não são web nunca chegam ao serviço de abertura do sistema;
- prefixos de fórmula no CSV são neutralizados; e
- a soma de prioridades satura em vez de sofrer estouro.

## Observações para publicação

- `.codex/`, `.build*`, `.swiftpm/`, `dist/`, `.DS_Store` e estados de usuário
  do Xcode estão excluídos.
- O arquivo acidental e não rastreado chamado `:-`, que continha apenas um
  cdhash, foi removido.
- `SECURITY.md` define um canal privado de divulgação para o futuro
  repositório.
- Regras importadas agora exigem ativação local explícita; essa alteração
  intencional de comportamento está documentada no `README.md`.

## Limitações residuais

- `MultitouchSupport` é um framework privado e não documentado da Apple. A ponte
  está isolada e possui drenagem preventiva, mas a vazão de callbacks e a
  latência de encerramento em dispositivo físico ainda devem ser validadas em
  cada combinação compatível de macOS e hardware. O fallback público do AppKit
  continua disponível.
- O aplicativo gerado utiliza assinatura ad hoc para desenvolvimento local. Uma
  distribuição pública do binário ainda exige identidade Developer ID,
  hardened runtime, notarização e validação do canal de lançamento. Isso não
  impede a publicação do código-fonte.
- Esta revisão estabelece a prontidão do código-fonte. Criação do repositório,
  primeiro commit, configuração do remoto e push são ações separadas de
  publicação.

## Documentos relacionados em PT-BR

- [Relatório do scan do Codex Security](relatorio-scan-codex-security.pt-BR.md)
- [Relatório de correções](relatorio-correcoes-seguranca.pt-BR.md)
- [Revisão de hardening](hardening-seguranca.pt-BR.md)
- [Evidências de validação](evidencias-validacao-seguranca.pt-BR.md)
