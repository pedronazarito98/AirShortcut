# Relatório do Scan de Segurança — AirShortcut

> Versão em português brasileiro do resultado técnico do Codex Security.
> O relatório original em inglês e seus artefatos JSON/SARIF permanecem
> preservados e selados para manter hashes, IDs e rastreabilidade.

Data da conclusão: 25/07/2026  
Scan: `41b26469-f170-4bb2-8b6a-b45ef25b5a43`  
Snapshot:
`codex-security-snapshot/v1:sha256:008173ea374f28087b410462bd64aa9e7acf39cf8efa8680a407430a4fc01003`

## Escopo

A revisão cobriu os 125 arquivos não ignorados que o Git incluiria na
publicação inicial: código Swift e C, testes, scripts, documentação e
metadados locais do projeto. Os diretórios gerados `.build*`, `.swiftpm/`,
`dist/` e `.codex/` ficaram fora do escopo por estarem ignorados e não serem
publicados.

Todos os 125 arquivos receberam comprovantes de leitura integral. Cada
candidato passou por descoberta, reconciliação, validação centralizada,
análise de caminho de ataque e decisão final.

## Resumo do scan original

| Severidade | Quantidade |
| --- | ---: |
| Crítica | 0 |
| Alta | 0 |
| Média | 3 |
| Baixa | 24 |
| Total reportável | 27 |

Não foram encontradas credenciais reutilizáveis, chaves privadas, tokens,
certificados, endereços de e-mail pessoais ou caminhos absolutos pessoais.

## Modelo de ameaça

### Ativos

- autoridade local do usuário para teclado, clipboard, aplicativos, janelas e
  Atalhos do macOS;
- permissão de Monitoramento de Entrada e, quando necessária, Acessibilidade;
- integridade das regras, workflows, perfis e bibliotecas de gestos;
- disponibilidade do processo não sandboxed;
- privacidade dos contatos brutos do trackpad e das gravações do laboratório;
- integridade do app preparado, assinado e executado pelo script local.

### Fronteiras de confiança

- arquivos JSON selecionados pelo usuário para importar regras e replays;
- persistência local carregada durante a inicialização;
- callbacks C/Swift do framework privado `MultitouchSupport`;
- eventos globais autorizados pelo TCC;
- ações que exercem autoridade local;
- arquivos temporários utilizados para preparar, verificar e executar o app;
- CSV aberto posteriormente em aplicativos de planilha.

### Capacidades consideradas do atacante

- criar um documento local malicioso e convencer o usuário a selecioná-lo;
- fornecer valores JSON extremos, coleções grandes ou estados ativados;
- disputar nomes previsíveis em diretórios temporários compartilhados;
- explorar comportamento inesperado da ABI privada do trackpad;
- inserir textos que sejam interpretados por planilhas como fórmulas.

Não foi considerado um canal remoto automático de ingestão, pois o produto
exige seleção local do arquivo.

## Achados confirmados

| Nº | Severidade | Título em PT-BR | Identificador |
| ---: | --- | --- | --- |
| 1 | Média | Diretório temporário previsível permite substituir, por condição de corrida local, o app iniciado pelo script de compilação | `as-b24-predictable-tmp-race-001` |
| 2 | Média | Regras importadas e ativadas tornam-se operacionais sem revisão de autoridade ou preparação desativada | `as-b16-import-activation-001` |
| 3 | Média | Observação global bruta do trackpad começa antes da autorização TCC | `as-trackpad-tcc-order-001` |
| 4 | Baixa | Decodificação sintetizada de workflows ignora limites de etapas, atrasos e timeouts | `as-workflow-decode-001` |
| 5 | Baixa | Timeout extremo importado de workflow encerra o editor ao renderizar o rótulo | `as-b20-workflow-editor-timeout-001` |
| 6 | Baixa | Ações de URL importadas ignoram a restrição HTTP/HTTPS do editor | `as-url-scheme-001` |
| 7 | Baixa | Regras importadas e ativadas podem controlar janelas sem consentimento de ativação | `airshortcut-imported-window-control-without-activation-consent` |
| 8 | Baixa | Timeout extremo importado de etapa causa falha na tarefa de timeout do workflow | `as-b13-step-timeout-003` |
| 9 | Baixa | Regras importadas e ativadas podem sintetizar teclas sem consentimento de ativação | `airshortcut-imported-keyboard-injection-without-activation-consent` |
| 10 | Baixa | Exportação CSV preserva prefixos de fórmula vindos de nomes de regras importadas | `as-b13-metrics-csv-004` |
| 11 | Baixa | Intervalos negativos de pressão importados encerram o processo durante a decodificação | `airshortcut-trackpad-trigger-pressure-range-crash` |
| 12 | Baixa | Prioridades importadas de regras e perfis podem estourar durante a ordenação | `as-priority-overflow-001` |
| 13 | Baixa | Frames de replay importados podem levar contatos ilimitados ao processamento e à interface principal | `as-b19-replay-contacts-002` |
| 14 | Baixa | Regras importadas e ativadas podem abrir esquemas arbitrários de URL sem consentimento | `airshortcut-imported-open-url-without-activation-consent` |
| 15 | Baixa | Amostras ilimitadas de gestos importados são recalculadas repetidamente no caminho de entrada ao vivo | `as-b02-custom-samples-002` |
| 16 | Baixa | Intervalo importado de sequência ignora limites e pode encerrar o agendamento do prazo | `as-b05-sequence-interval-001` |
| 17 | Baixa | Regras importadas e ativadas podem controlar aplicativos sem consentimento | `airshortcut-imported-application-control-without-activation-consent` |
| 18 | Baixa | Timeout negativo extremo de workflow causa falha na conversão para inteiro da mensagem de erro | `as-b13-workflow-timeout-001` |
| 19 | Baixa | Atraso extremo importado de etapa causa falha na conversão para duração do `Task.sleep` | `as-b13-step-delay-002` |
| 20 | Baixa | Frames de replay aceitam listas ilimitadas de contatos e amplificam uso de memória e CPU | `airshortcut-replay-unbounded-touch-array-dos` |
| 21 | Baixa | Timeout extremo importado de etapa encerra o editor durante a renderização | `as-b20-step-editor-timeout-002` |
| 22 | Baixa | Regras importadas e ativadas podem executar Atalhos do macOS sem consentimento | `airshortcut-imported-macos-shortcut-without-activation-consent` |
| 23 | Baixa | Regras importadas e ativadas podem sobrescrever o clipboard sem consentimento | `airshortcut-imported-clipboard-write-without-activation-consent` |
| 24 | Baixa | Timestamps extremos de replay causam falha na conversão para duração do `Task.sleep` | `as-b11-replay-timestamp-001` |
| 25 | Baixa | Selecionar um template importado calcula e renderiza sincronamente trajetórias ilimitadas | `as-b16-library-gesture-dos-002` |
| 26 | Baixa | Importação de replay decodifica e mantém em memória um documento ilimitado | `as-replay-import-bounds-001` |
| 27 | Baixa | Tolerância importada de gesto personalizado ignora limites e pode corresponder a gestos não relacionados | `as-b02-custom-tolerance-001` |

## Confiança e limitações do scan

Os achados confirmados possuem rastreamento direto entre a entrada menos
confiável, o controle ausente ou contornado e o ponto concreto de impacto. A
severidade permaneceu média ou baixa porque os caminhos exigem interação local
do usuário e afetam uma única sessão local, sem ingestão remota automática.

Uma preocupação sobre o ciclo de vida do callback privado foi adiada no scan
original porque o contrato de drenagem do framework da Apple não pôde ser
provado sem hardware. Mesmo assim, a correção posterior adicionou retenção
explícita do contexto e drenagem dos callbacks em andamento.

## Situação após as correções

Os 27 achados foram corrigidos e verificados. Consulte:

- [Revisão final de segurança](security-review.md)
- [Relatório de correções](relatorio-correcoes-seguranca.pt-BR.md)
- [Evidências de validação](evidencias-validacao-seguranca.pt-BR.md)
- [Revisão de hardening](hardening-seguranca.pt-BR.md)

