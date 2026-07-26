# Política de Segurança

## Versões compatíveis

O AirShortcut ainda está em fase de pré-lançamento. As correções de segurança
são aplicadas somente à revisão mais recente.

## Como relatar uma vulnerabilidade

Não abra uma issue pública para uma possível vulnerabilidade. Depois que o
repositório for publicado, utilize o fluxo **Security → Report a
vulnerability** do GitHub para manter os detalhes em sigilo. Inclua:

- a revisão afetada e a versão do macOS;
- os passos para reprodução ou uma fixture mínima;
- o impacto observado;
- se o problema exige permissão de Monitoramento de Entrada ou Acessibilidade.

Não inclua credenciais reais, documentos privados ou gravações pessoais do
trackpad. Substitua valores sensíveis por exemplos sintéticos.

## Fronteiras de segurança

O AirShortcut processa arquivos JSON selecionados pelo usuário e pode executar
automações locais com a autoridade do usuário atual. Regras importadas são
validadas e sempre entram desativadas até serem revisadas e ativadas localmente.

O provedor avançado de trackpad carrega dinamicamente o framework não
documentado `MultitouchSupport`, da Apple. Ele está isolado atrás de uma pequena
ponte C, exige autorização para entrada global e utiliza as APIs públicas do
AppKit como fallback quando não está disponível. Esse modo experimental não é
compatível com distribuição pela Mac App Store e pode exigir manutenção depois
de atualizações do macOS.

Comandos de shell e AppleScript exigem aprovação explícita vinculada ao
conteúdo exato. Qualquer alteração nesse conteúdo invalida a aprovação
anterior.
