# Tico — validação do Marco E

Data: 2026-07-26

## Release candidate

- Textos públicos restantes foram migrados de AirShortcut para Tico.
- Nomes internos de módulo, executável, bundle ID, notificações e logs foram
  preservados por compatibilidade.
- Menu Bar Extra agora usa `TicoMenuBarTemplate` com indicador discreto de
  captura.
- README e documentação de distribuição usam os artefatos `Tico.app` e
  `Tico.zip`.
- O fluxo `--release-package` produz build SwiftPM otimizado.
- O fluxo de assinatura real adiciona Hardened Runtime e timestamp.
- `script/notarize_release.sh` automatiza envio, espera, stapling, recriação do
  ZIP e validação.

## QA

- QA visual e funcional manual: aprovado pelo responsável pelo produto.
- A inspeção automatizada da janela permaneceu indisponível por falha da ponte
  local de captura; o aceite manual cobre essa lacuna para este marco.

## Assinatura pública

- Identidades válidas encontradas no Keychain: `0`.
- Estado atual: assinatura ad hoc para desenvolvimento e QA local.
- Bloqueio para distribuição pública: instalar um certificado
  `Developer ID Application` e configurar um perfil do `notarytool`.
- Esse bloqueio não impede gerar e validar o release candidate local.

## Validações finais

- `TicoBrandTests`: 6 testes, 0 falhas.
- Suíte SwiftPM completa: 107 testes, 0 falhas.
- `bash -n script/build_and_run.sh`: aprovado.
- `bash -n script/notarize_release.sh`: aprovado.
- `git diff --check`: aprovado.
- `./script/build_and_run.sh --release-package`: aprovado.
- Build de produção: aprovado.
- `Tico.zip` extraído em diretório limpo sob `/private/tmp`.
- `codesign --verify --deep --strict`: aprovado no app extraído.
- Hardened Runtime confirmado pelo flag de assinatura `runtime`.
- Metadados confirmados:
  - nome público: `Tico`;
  - executável: `AirShortcut`;
  - bundle identifier: `com.pedronazarito.AirShortcut`.
- Release candidate otimizado abriu e manteve o processo em execução.
- O script de notarização recusou corretamente continuar sem
  `TICO_NOTARYTOOL_PROFILE`.
- O Gatekeeper retornou erro interno de Code Signing para a assinatura ad hoc;
  esse resultado não equivale a aceite público e é esperado enquanto não
  houver cadeia Developer ID/notarização.
- SHA-256 do RC local:
  `1d9100769d03b20d62dbd84270ef2e7c55ec2a1298b069a5bc0bb08cb755b2c0`.

## Conclusão

O Marco E está concluído como release candidate local. A distribuição pública
permanece pendente exclusivamente das credenciais Apple: certificado Developer
ID Application e perfil de notarização no Keychain.
