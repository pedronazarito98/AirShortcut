# Evidências de Validação de Segurança — AirShortcut

Data: 25/07/2026

## Integridade do scan

- Scan: `41b26469-f170-4bb2-8b6a-b45ef25b5a43`
- Estado: selado e concluído.
- Cobertura original: 125 de 125 candidatos à publicação com comprovantes de
  revisão integral.
- Achados detalhados: 27 de 27 com relatório, validação e análise de caminho de
  ataque.
- Portfólio de hardening: 4 oportunidades estruturais e 8 alternativas.
- Artefatos canônicos preservados: manifesto, cobertura, achados, Markdown e
  SARIF.

## Testes automatizados

### Regressões de segurança

Comando:

```sh
swift test --disable-sandbox --filter SecurityRegressionTests
```

Resultado: 8 testes aprovados e nenhuma falha.

Cobertura:

- rejeição atômica de prioridade, timeout, atraso, URL e intervalo de pressão
  malformados;
- rejeição de documento acima do limite antes da decodificação;
- rejeição de contatos e duração excessivos em replay;
- aceitação de replay legítimo e limitado;
- bloqueio do provedor quando o TCC nega entrada global;
- rejeição de esquemas de URL não web;
- neutralização de fórmulas no CSV;
- soma de prioridades sem estouro.

### Suíte completa

Comando:

```sh
swift test --disable-sandbox
```

Resultado: 97 testes aprovados e nenhuma falha.

Isso confirma que documentos legados, regras atuais, workflows, perfis,
templates, reconhecimento de gestos, replay, fallback e serviços de ação
continuam funcionando.

## Compilação e pacote

Comandos:

```sh
bash -n script/build_and_run.sh
./script/build_and_run.sh --package
```

Resultado: sintaxe válida e compilação do produto `AirShortcut` concluída.

O script utiliza um diretório exclusivo criado por `mktemp`, com modo 0700, e
subdiretórios separados para preparação, execução e verificação.

## Assinatura da distribuição

O arquivo `dist/AirShortcut.zip` foi extraído para um diretório temporário
independente. Depois da remoção de atributos estendidos, o app extraído foi
verificado com:

```sh
codesign --verify --deep --strict --verbose=2 AirShortcut.app
```

Resultado:

- válido em disco;
- satisfaz o requisito designado;
- identificador `com.pedronazarito.AirShortcut`;
- binário Mach-O arm64;
- assinatura ad hoc de desenvolvimento.

## Higiene para o GitHub

A lista final contém 131 candidatos à publicação. Foram procurados:

- cabeçalhos de chaves privadas;
- tokens com formatos conhecidos do GitHub, OpenAI, AWS, Google e Slack;
- atribuições de senha, chave de API, client secret e access token;
- arquivos `.env`, `.pem`, `.p12`, `.pfx`, `.key`, keystores e perfis de
  provisionamento;
- caminhos absolutos pessoais em `/Users/` e `/home/`;
- arquivos gerados ou metadados locais.

Resultado: nenhuma credencial, chave, token, caminho pessoal ou arquivo
sensível encontrado.

Itens ignorados corretamente:

- `.build/` e `.build-26/`;
- `.swiftpm/`;
- `.codex/`;
- `dist/`;
- `.DS_Store`;
- estados de usuário do Xcode.

O arquivo acidental `:-`, que continha somente um cdhash, foi removido.

## Limitações explícitas

- Não foi realizada medição física de vazão e latência da ponte
  `MultitouchSupport`.
- O framework é privado e pode mudar entre versões do macOS.
- O pacote é adequado para desenvolvimento local. Distribuição pública do
  binário exige Developer ID, hardened runtime e notarização.
- Essas limitações não bloqueiam a publicação segura do código-fonte.
