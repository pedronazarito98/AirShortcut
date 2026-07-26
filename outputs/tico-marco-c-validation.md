# Tico — validação do Marco C

Data: 2026-07-26

## Contrato do pacote

- Nome público do bundle: `Tico`.
- Artefato local: `dist/Tico.app`.
- Arquivo de distribuição: `dist/Tico.zip`.
- Produto SwiftPM e executável: `AirShortcut`.
- Caminho do executável: `Tico.app/Contents/MacOS/AirShortcut`.
- Bundle identifier preservado: `com.pedronazarito.AirShortcut`.
- Requisito designado de desenvolvimento preservado para continuidade do TCC.
- Ícone público: `Tico.icns`.
- Resource bundle técnico preservado:
  `AirShortcut_AirShortcut.bundle`.

## Verificações

- `bash -n script/build_and_run.sh`: aprovado.
- `git diff --check`: aprovado.
- `./script/build_and_run.sh --package`: aprovado.
- `plutil -lint dist/Tico.app/Contents/Info.plist`: aprovado.
- Metadados conferidos:
  - `CFBundleName`: `Tico`;
  - `CFBundleDisplayName`: `Tico`;
  - `CFBundleExecutable`: `AirShortcut`;
  - `CFBundleIdentifier`: `com.pedronazarito.AirShortcut`;
  - `CFBundleIconFile`: `Tico.icns`.
- Estrutura conferida:
  - executável arm64 em `Contents/MacOS/AirShortcut`;
  - ícone válido em `Contents/Resources/Tico.icns`;
  - sete assets dentro de `AirShortcut_AirShortcut.bundle`;
  - artefatos legados `dist/AirShortcut.app` e `dist/AirShortcut.zip`
    removidos pelo empacotador.
- Assinatura:
  - identificador `com.pedronazarito.AirShortcut`;
  - requisito `designated => identifier "com.pedronazarito.AirShortcut"`;
  - `codesign --verify --deep --strict` aprovado no bundle local;
  - ZIP extraído sob `/private/tmp` e assinatura estrita aprovada.
- Runtime:
  - `--verify`: aprovado;
  - `--laboratory-verify`: aprovado;
  - `--fallback-diagnostic`: aprovado e registrou a ativação do fallback
    público.
- Suíte SwiftPM: 103 testes, 0 falhas.

## Resultado

Marco C concluído. O produto agora é distribuído publicamente como `Tico`,
mantendo a identidade técnica necessária para dados, logs e permissões.
