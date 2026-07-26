# Tico — validação do Marco B

Data: 2026-07-26

## Resultado

Marco B concluído.

## Implementação

- `TicoBrand` separa nome público e identidade técnica legada.
- Seis tokens adaptativos usam valores próprios para light e dark mode.
- `TicoMarkView` seleciona automaticamente símbolo ou wordmark conforme a
  aparência do sistema.
- O app usa a cor primária como tint global.
- Janela, sidebar e Menu Bar Extra recebem o nome público por uma única fonte.
- A visão geral mostra o wordmark e um painel de marca adaptativo.
- Cores nativas de sucesso, alerta e erro permanecem semânticas.
- O empacotador copia o resource bundle para
  `Contents/Resources/AirShortcut_AirShortcut.bundle`.
- O runtime localiza resources empacotados e mantém fallback para SwiftPM em
  desenvolvimento e testes.

## Testes

- 6 testes específicos de identidade:
  - nomes público e técnico;
  - valores hex light/dark;
  - seleção de assets por aparência;
  - presença de todos os resources;
  - contraste mínimo de texto;
  - renderização do wordmark em light e dark mode.
- Suíte completa: 103 testes, 0 falhas.
- `bash -n script/build_and_run.sh`: aprovado.
- `git diff --check`: aprovado.

## Pacote

- `dist/AirShortcut.app` contém os sete assets no resource bundle.
- `dist/AirShortcut.zip` foi extraído em `/private/tmp`.
- O app extraído passou em `codesign --verify --deep --strict`.
- O app empacotado abriu e permaneceu em execução sem erro de carregamento dos
  resources.

## Limite

A inspeção visual automatizada da janela não pôde ser capturada porque o
canal local de Computer Use encerrou antes de retornar a imagem. A composição
foi coberta por renderização SwiftUI em light e dark mode, mas uma revisão
visual humana da janela continua recomendada antes do release candidate.
