# Distribuição do Tico

## Estado atual

O projeto gera `dist/Tico.app` e `dist/Tico.zip`. Sem uma identidade Developer
ID configurada, ambos recebem assinatura ad hoc e servem somente para
desenvolvimento e QA local.

O caminho previsto é distribuição direta fora da Mac App Store, porque a
captura avançada usa um framework privado da Apple.

## O que já está automatizado

- build otimizado com `./script/build_and_run.sh --release-package`;
- Hardened Runtime e timestamp quando uma identidade real é informada;
- envio, espera, stapling e validações em `script/notarize_release.sh`;
- verificação local do ZIP com `script/release_preflight.sh`.

## O que ainda depende do proprietário

1. Participar do Apple Developer Program.
2. Instalar um certificado **Developer ID Application** no Keychain.
3. Criar um perfil do `notarytool` no Keychain.
4. Gerar e assinar o release candidate com a identidade real.
5. Notarizar, aplicar e validar o ticket.
6. Confirmar `spctl` como aceito e abrir o mesmo artefato em ambiente limpo.

Certificados, senhas, perfis e logs sensíveis nunca devem entrar no
repositório.

## Comandos

```sh
export AIRSHORTCUT_CODESIGN_IDENTITY="Developer ID Application: NOME (TEAMID)"
./script/build_and_run.sh --release-package

export TICO_NOTARYTOOL_PROFILE="TicoNotary"
./script/notarize_release.sh
```

Depois:

```sh
codesign --verify --deep --strict --verbose=2 dist/Tico.app
xcrun stapler validate dist/Tico.app
spctl -a -vv --type execute dist/Tico.app
```

Uma assinatura ad hoc aprovada por `codesign` não substitui Developer ID,
notarização, Gatekeeper ou teste em máquina limpa.
