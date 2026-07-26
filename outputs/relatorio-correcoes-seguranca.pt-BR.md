# Relatório de Correções de Segurança — AirShortcut

Scan de origem: `41b26469-f170-4bb2-8b6a-b45ef25b5a43`

## Resultado

`corrigido`

Todos os 27 achados reportáveis foram corrigidos na árvore de trabalho atual.
A preocupação originalmente adiada sobre o ciclo de vida do callback do
framework privado também recebeu reforço preventivo.

## Fechamento das fronteiras de segurança

- Documentos de regras e replay agora possuem leituras limitadas e validação
  semântica.
- Documentos inválidos são rejeitados atomicamente antes de chegarem à
  persistência, interface, agendamento, correspondência ou execução de ações.
- Regras importadas sempre entram desativadas.
- Abertura de URLs está limitada a HTTP e HTTPS.
- Agendamento de workflows e formatação no editor rejeitam estados numéricos
  inseguros.
- O replay mantém somente um frame pendente, em vez de uma closure agendada
  para cada frame.
- O provedor de trackpad não inicia sem uma autorização atualizada para entrada
  global.
- A ponte C remove a elegibilidade de novos callbacks e drena os callbacks em
  andamento antes de liberar o contexto Swift.
- A preparação do build usa um diretório temporário privado e exclusivo.
- A saída CSV das métricas neutraliza prefixos interpretáveis como fórmulas.

## Comportamento preservado

Continuam cobertos pela suíte completa:

- documentos de regras legados e da versão 6;
- intervalos válidos de pressão do trackpad;
- regras criadas localmente e ativadas;
- replay determinístico;
- fallback público do trackpad;
- ações e workflows já existentes.

## Áreas alteradas

- `Sources/AirShortcut/Support/DocumentSecurityPolicy.swift`
- validação de modelos, intervalos e pontos finais de workflow;
- provedor, gravador e processamento de contatos de replay;
- importação e estado de ativação no armazenamento;
- permissão e ciclo de vida dos callbacks do trackpad;
- pontos finais de URL e métricas;
- `script/build_and_run.sh`;
- testes de segurança e documentação para publicação.

## Etapas de verificação

1. Aplicabilidade e capacidade de compilação — aprovadas.
   - `bash -n script/build_and_run.sh`
   - `./script/build_and_run.sh --package`
2. Fechamento de segurança — aprovado.
   - `swift test --disable-sandbox --filter SecurityRegressionTests`
   - 8 testes, 0 falhas.
3. Revisão de contornos após as mudanças — aprovada.
   - Nenhum caminho temporário previsível corrigido, caminho pessoal absoluto,
     chave privada ou valor com formato de credencial foi encontrado entre os
     candidatos à publicação.
4. Preservação de comportamento — aprovada.
   - Os testes de compatibilidade de documentos legados, atuais e de replay
     passaram.
5. Verificações do repositório — aprovadas.
   - `swift test --disable-sandbox`
   - 97 testes, 0 falhas.
   - O app extraído de `dist/AirShortcut.zip` passou em
     `codesign --verify --deep --strict`.

## Incerteza remanescente

O framework privado `MultitouchSupport` continua sem suporte oficial da Apple.
A drenagem do callback está implementada e compilada pela suíte, mas a vazão
com trackpad físico e a latência de encerramento não foram medidas nesta
execução. Trata-se de uma limitação de validação em hardware, não de um achado
aberto para publicação do código-fonte.

Uma distribuição pública do binário também exige assinatura Developer ID e
notarização. Isso não impede a publicação do código-fonte.

