# Tico — Developer ID e notarização, sem mistério

## O que cada etapa significa

### 1. Developer ID

É o certificado da sua conta Apple usado para assinar um app distribuído fora
da Mac App Store. Ele permite que o macOS confirme quem publicou o Tico e que o
app não foi alterado depois da assinatura.

O certificado necessário é do tipo **Developer ID Application**. O certificado
fica no Keychain do Mac; ele não deve ser colocado no repositório.

### 2. Hardened Runtime

É um conjunto de proteções aplicado durante a assinatura. A Apple exige isso
para notarizar apps. O script de release já usa `--options runtime`.

### 3. Notarização

Depois de assinado, o ZIP é enviado automaticamente para a Apple. A Apple
analisa o pacote e devolve um resultado. Ela não publica o app: apenas registra
que aquele arquivo foi analisado.

### 4. Stapling

Quando a notarização é aprovada, o comprovante é anexado ao `Tico.app`. Assim,
outro Mac consegue verificar o app mesmo quando está offline.

## O que já está pronto

- Build otimizado com `--release-package`.
- Assinatura Developer ID com Hardened Runtime e timestamp quando
  `AIRSHORTCUT_CODESIGN_IDENTITY` estiver configurada.
- Envio, espera do resultado, stapling e validação em
  `script/notarize_release.sh`.
- Nenhuma senha ou chave é gravada no projeto.

## O que ainda depende de você

1. Participar do Apple Developer Program.
2. Criar ou instalar neste Mac um certificado **Developer ID Application**.
3. Criar uma senha específica de app no site da conta Apple.
4. Guardar a credencial de notarização no Keychain.

O comando da etapa 4 é interativo e deve ser executado por você:

```sh
xcrun notarytool store-credentials "TicoNotary" \
  --apple-id "SEU_APPLE_ID" \
  --team-id "SEU_TEAM_ID" \
  --password "SENHA_ESPECIFICA_DE_APP"
```

A senha é armazenada pelo Keychain, não pelo repositório.

## Como gerar e notarizar

Depois que o certificado e o perfil estiverem instalados:

```sh
export AIRSHORTCUT_CODESIGN_IDENTITY="Developer ID Application: SEU NOME (TEAMID)"
./script/build_and_run.sh --release-package

export TICO_NOTARYTOOL_PROFILE="TicoNotary"
./script/notarize_release.sh
```

Ao final, `dist/Tico.zip` será recriado com o ticket anexado.

## Como conferir

```sh
codesign --verify --deep --strict --verbose=2 dist/Tico.app
xcrun stapler validate dist/Tico.app
spctl -a -vv --type execute dist/Tico.app
```

O resultado esperado do `spctl` é `accepted` com origem `Notarized Developer
ID`.

## Situação atual deste Mac

Na inspeção de 2026-07-26, o Keychain retornou `0 valid identities found`.
Portanto, o release candidate atual pode ser compilado, testado e assinado de
forma ad hoc, mas ainda não pode ser apresentado como distribuição pública
assinada/notarizada.
