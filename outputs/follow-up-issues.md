# AirShortcut — issues de acompanhamento

Registro local de gaps para criação no tracker público quando o proprietário
decidir publicar o repositório. Todos permanecem **OPEN**; este documento não
substitui a execução dos critérios de aceite.

## ISSUE-01 — Definir licença open source

**Estado**: OPEN / release blocker  
**Escopo**: RR-05

O repositório não possui `LICENSE`. A escolha tem implicações legais e não
será inferida pelo agente.

Critérios de aceite:

- o proprietário escolhe explicitamente uma licença;
- compatibilidade com dependências e objetivo de distribuição é revisada;
- `LICENSE` contém o texto oficial sem alterações;
- README e checklist apontam para a licença escolhida.

## ISSUE-02 — Executar matriz física no trackpad interno

**Estado**: OPEN / physical-support blocker  
**Escopo**: RR-07, RR-08, RR-10

Critérios de aceite:

- executar permission denied, private capture/capability, tap, hold, quatro
  swipes, pinch, rotação, sleep/wake, fallback e observação de falso positivo;
- observar manualmente o pass-through de teclado e mouse;
- registrar PASS/FAIL/NOT-RUN com expected, observed e notes;
- validar o relatório sanitizado antes do commit.

## ISSUE-03 — Executar matriz física no Magic Trackpad

**Estado**: OPEN / physical-support blocker  
**Escopo**: RR-07, RR-10

Critérios de aceite:

- executar a matriz de gestos em Magic Trackpad identificado apenas por classe;
- desconectar e reconectar fisicamente o dispositivo;
- registrar comportamento de capability/fallback e eventuais falhas;
- não publicar serial, TCC, username ou frames brutos.

## ISSUE-04 — Produzir artefato Developer ID verificável

**Estado**: OPEN / distribution blocker  
**Escopo**: RR-13, RR-14

Critérios de aceite:

- usar identidade Developer ID Application fornecida pelo proprietário fora do
  repositório;
- habilitar Hardened Runtime e verificar app/código aninhado;
- obter aceitação do `notarytool` ligada ao SHA-256 publicado;
- anexar o ticket e passar `stapler validate`;
- passar `spctl` e abrir o mesmo artefato em máquina ou usuário limpo;
- publicar somente evidência sanitizada, sem credenciais.

## ISSUE-05 — Confirmar gate remoto do GitHub Actions

**Estado**: OPEN / evidence gap  
**Escopo**: RR-01, RR-03

Critérios de aceite:

- observar execução real do workflow em pull request ou push para `main`;
- confirmar falha controlada em branch descartável e sucesso após restauração;
- preservar o resumo que separa automação, hardware e distribuição;
- referenciar o run público no checklist sem copiar logs sensíveis.

## ISSUE-06 — Executar Verifier independente

**Estado**: OPEN / initiative close gate  
**Escopo**: RR-15–RR-18

Critérios de aceite:

- um agente que não participou da autoria rederiva RR-01–RR-18;
- cada AC recebe evidência `file:line` ou gap;
- 1–3 mutações em scratch são mortas pelos testes ou viram fix tasks;
- `.specs/features/release-readiness/validation.md` registra veredito, range,
  gates, UAT e sensor sem alterar o conteúdo congelado do autor.
