# Tico — validação do Marco D

Data: 2026-07-26

## Resultado

Marco D concluído para os contratos automatizáveis.

## Compatibilidade de dados

- `ShortcutStore`, `EventLogStore` e `MetricsStore` continuam usando
  `Application Support/AirShortcut`.
- O nome do diretório legado está centralizado em
  `TicoBrand.legacyApplicationSupportDirectoryName`.
- Uma instalação simulada criada como AirShortcut foi reaberta pelo código
  atual sem mover ou recriar dados.
- Permaneceram idênticos:
  - regras;
  - perfis;
  - workflows;
  - gestos personalizados;
  - presets;
  - histórico de execução;
  - métricas.
- A simulação confirma que `Application Support/Tico` não é criado.
- A versão do documento de regras permanece `6`.

## Compatibilidade de preferências

- O prefixo legado está centralizado em
  `TicoBrand.legacyUserDefaultsPrefix`.
- Preferências gerais continuam em `com.airshortcut.settings.*`.
- Calibração, validação, aprovações de automação e capacidades do trackpad
  continuam nas chaves `com.airshortcut.*`.
- Os testes confirmam leitura e escrita nas chaves antigas e ausência de
  escrita em `com.tico.*`.

## Identidade e permissões

- Bundle identifier preservado:
  `com.pedronazarito.AirShortcut`.
- Executável preservado: `AirShortcut`.
- Requisito designado preservado:
  `designated => identifier "com.pedronazarito.AirShortcut"`.
- Esses valores mantêm o contrato necessário para continuidade do TCC.
- A confirmação definitiva entre releases públicas exigirá o mesmo
  certificado Developer ID; builds ad hoc não substituem essa prova.

## Testes

- `TicoCompatibilityTests`: 4 testes, 0 falhas.
- Suíte SwiftPM completa: 107 testes, 0 falhas.
- `bash -n script/build_and_run.sh`: aprovado.
- `git diff --check`: aprovado.
- `dist/Tico.zip` regenerado e extraído sob `/private/tmp`.
- `codesign --verify --deep --strict`: aprovado no app extraído.
- Assinatura inspecionada:
  - executável: `Contents/MacOS/AirShortcut`;
  - identificador: `com.pedronazarito.AirShortcut`;
  - requisito: `designated => identifier "com.pedronazarito.AirShortcut"`;
  - estado: ad hoc, adequado apenas para desenvolvimento local.
- SHA-256 de `dist/Tico.zip`:
  `9717fc48e1538347c39b406a499ff64318e28e1e5a1faf613329810451586618`.

## Política para migração futura

Uma futura mudança física para `Application Support/Tico` não deve ser feita
como simples rename. Ela precisa de cópia atômica, validação, rollback e
fallback de leitura para `Application Support/AirShortcut`.
