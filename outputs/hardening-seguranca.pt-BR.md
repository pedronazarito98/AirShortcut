# Revisão de Hardening de Segurança — AirShortcut

## Base de evidências

Esta revisão utiliza os 27 achados reportáveis do scan
`41b26469-f170-4bb2-8b6a-b45ef25b5a43`, o modelo de ameaça, os artefatos de
cobertura e a inspeção direta do snapshot analisado.

As evidências apontaram quatro oportunidades estruturais recorrentes. Dois
outros achados — diretórios temporários previsíveis e prefixos de fórmula em
CSV — foram tratados como correções locais, pois incluí-los em um projeto
arquitetural maior reduziria a clareza de responsabilidade.

## Restrições

A arquitetura mantém:

- o aplicativo macOS em SwiftPM;
- o fallback público para o trackpad;
- compatibilidade JSON quando segura;
- a arquitetura de sessões de contato e reconhecimento de gestos.

Não havia medições iniciais de latência, memória, vazão ou tempo de drenagem dos
callbacks em hardware. Por isso, decisões de recursos foram acompanhadas de
limites explícitos e planos de validação.

## Portfólio de oportunidades

| Oportunidade | Evidência | Alternativas | Recomendação adotada |
| --- | --- | --- | --- |
| Centralizar a política de documentos não confiáveis | 13 achados de decodificação, intervalos, coleções, URLs e consumidores em runtime | Normalizadores por modelo; fronteira central de documento validado | Adotar uma política central de aceitação e manter proteções locais nos pontos finais |
| Preparar com segurança a ativação de automações privilegiadas | Causa raiz da importação ativada e 6 achados ligados às capacidades das ações | Desativar ao importar; concessão de capacidades vinculada à revisão | Desativar toda regra importada imediatamente; considerar concessões por capacidade se o compartilhamento crescer |
| Limitar o replay da leitura até a renderização | 4 achados de alocação, timestamp, agendamento e renderização | Documento limitado em memória; janela de streaming | Utilizar documento limitado em memória até que medições reais justifiquem streaming |
| Conter a autoridade e o ciclo de vida do provedor | Ordem do TCC e evidência adiada sobre o ciclo de vida da ponte | Verificação compartilhada e barreira de drenagem; proprietário central de sessão | Adotar verificação compartilhada e drenagem; centralizar toda a sessão somente se a complexidade do provedor crescer |

## Recomendações

### 1. Política central de documentos

Uma única política deve ser responsável pelos limites de bytes, coleções,
textos, números, intervalos, workflows, URLs e templates. O armazenamento só
deve receber dados depois que todo o documento for aceito atomicamente.

Implementação escolhida:

- leitura limitada antes da decodificação;
- `DocumentSecurityPolicy` como política central;
- decodificação segura de intervalos;
- rejeição integral sem publicação parcial;
- defesas adicionais nos pontos finais de URL, workflow e prioridade.

### 2. Ativação segura de automações

O estado `isEnabled` não deve transportar consentimento entre máquinas ou
documentos. Uma regra compartilhada contém configuração, mas não a autorização
do usuário local.

Implementação escolhida:

- toda regra importada entra desativada;
- substituições com o mesmo identificador também entram desativadas;
- Shell e AppleScript mantêm aprovação separada por conteúdo exato;
- a interface e o `README.md` explicam a necessidade de revisão e ativação.

Como evolução futura, um manifesto de capacidades poderia listar ações como
teclado, clipboard, aplicativos, janelas e Atalhos do macOS, vinculando o
consentimento à revisão exata da regra.

### 3. Fluxo de replay limitado

Limitar somente o tamanho do arquivo não controla a expansão de arrays,
quantidade agregada de contatos ou trabalho agendado.

Implementação escolhida:

- máximo de 8 MiB por documento;
- máximo de 10.000 frames;
- máximo de 32 contatos por frame e 100.000 contatos agregados;
- duração máxima de 24 horas;
- validação de valores finitos, timestamps monotônicos e textos;
- agendamento de um frame por vez;
- limites equivalentes na gravação, processamento e publicação.

Streaming passa a ser preferível somente se sessões legítimas ultrapassarem
esses limites de forma comprovada.

### 4. Autoridade e ciclo de vida do provedor

Iniciar o provedor bruto antes da verificação do TCC enfraquecia a fronteira de
privacidade. Além disso, um ponteiro Swift não retido dependia de um contrato
implícito de drenagem do framework privado.

Implementação escolhida:

- atualização e verificação de Monitoramento de Entrada/Acessibilidade antes do
  início do provedor;
- encerramento do provedor quando a criação do event tap falha;
- contexto de callback Swift explicitamente retido;
- remoção da elegibilidade de novos callbacks antes do encerramento;
- contador e condição para drenar callbacks em andamento antes da liberação.

## Riscos residuais e decisões futuras

- Medir vazão, latência p95 de entrega e latência de encerramento com trackpads
  físicos compatíveis.
- Avaliar um proprietário central de sessão caso sejam adicionados múltiplos
  dispositivos simultâneos, troca frequente de provedor ou revogação dinâmica
  de permissões.
- Avaliar manifesto de capacidades se o compartilhamento de regras se tornar
  uma funcionalidade central do produto.
- Avaliar replay por streaming se sessões reais excederem os limites definidos.

As correções escolhidas preservam a arquitetura atual e fecham as fronteiras
confirmadas sem exigir uma reescrita concorrente do produto.

