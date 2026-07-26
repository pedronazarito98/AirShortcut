# AirShortcut — plano completo de funcionalidades avançadas

## 1. Objetivo

Evoluir o AirShortcut de um executor de gestos discretos para uma plataforma
local de automação por trackpad, mantendo como diferenciais:

- gestos globais de dois a cinco dedos;
- reconhecimento de contatos individuais;
- configuração visual sem código;
- execução previsível e auditável;
- funcionamento local, sem enviar gestos ou automações para servidores;
- degradação segura quando a API privada do trackpad não estiver disponível.

Este plano cobre:

- TipTap e acordes de dedos;
- toque duplo e triplo;
- sequências de gestos;
- gestos personalizados graváveis;
- ações contínuas;
- perfis e condições por aplicativo;
- pressão e Force Touch;
- automação de janelas;
- cadeias de ações;
- visualizador e calibrador;
- detecção de conflitos;
- sensibilidade, velocidade e regiões;
- múltiplos trackpads;
- presets;
- integração com Atalhos do macOS;
- histórico e métricas;
- supressão opcional do evento original, onde tecnicamente possível.

## 2. Estado atual

O AirShortcut já entrega a base do planejamento inicial:

- CRUD e persistência versionada de regras;
- importação e exportação;
- captura global de teclado e botões de mouse;
- captura global experimental de contatos brutos do trackpad;
- toque, segurar, swipe, pinça e rotação;
- configuração de dois a cinco dedos e região inicial;
- gravador de gatilho;
- execução de app, URL, notificação e script;
- confirmação de scripts;
- permissões, menu bar, login item e histórico;
- fallback público para gestos do sistema;
- testes unitários e telemetria local.

O modelo atual produz um `InputEventDescriptor` somente depois que um gesto foi
reconhecido. Ele é suficiente para ações discretas, mas não representa:

- dedos que entram e saem durante a mesma sessão;
- fases contínuas do gesto;
- confiança e competição entre reconhecedores;
- uma sequência de gestos;
- progresso usado para volume, brilho ou tamanho de janela;
- dispositivo físico de origem;
- amostras necessárias para treinar gestos personalizados.

Portanto, a primeira entrega não deve adicionar casos diretamente ao
`AdvancedTrackpadRecognizer`. Primeiro é necessário criar um motor de sessões de
contato que permaneça independente da UI e das ações.

## 3. Princípios técnicos

1. **SwiftUI permanece fonte de verdade da interface.**
   AppKit deve aparecer apenas em pontes pequenas para janela, workspace,
   painéis e comportamento que SwiftUI não cobre.

2. **Frames brutos não chegam ao `AppController`.**
   O controlador recebe eventos semânticos ou progresso já normalizado.

3. **Reconhecedores são determinísticos e testáveis por replay.**
   Nenhum teste de regra deve depender do trackpad físico.

4. **Gestos discretos e contínuos usam contratos diferentes.**
   Abrir um app é um comando; alterar volume é uma sessão com início, mudança,
   término e cancelamento.

5. **A API privada fica isolada.**
   O restante do produto deve funcionar quando `MultitouchSupport` falhar.

6. **Nenhuma ação perigosa é ampliada silenciosamente.**
   Scripts, AppleScript e fluxos importados exigem inspeção e política explícita.

7. **Compatibilidade é capacidade detectada, não suposição.**
   Pressão, múltiplos dispositivos, brilho e supressão devem aparecer apenas
   quando o Mac puder executá-los.

## 4. Arquitetura-alvo

```text
MultitouchSupport / NSEvent / replay de teste
                    │
                    ▼
          TrackpadFrameProvider
                    │
                    ▼
          ContactSessionEngine
                    │
                    ▼
          GestureFeatureExtractor
                    │
       ┌────────────┼─────────────┐
       ▼            ▼             ▼
   Tap/Chord     Path/Custom    Continuous
   Recognizer    Recognizer     Recognizer
       └────────────┼─────────────┘
                    ▼
             GestureArbiter
                    │
                    ▼
              GestureEvent
                    │
                    ▼
       ContextualRuleEvaluator
                    │
                    ▼
         ActionWorkflowExecutor
```

### 4.1 Provedores de frames

Criar o protocolo `TrackpadFrameProvider`:

- `MultitouchFrameProvider`: adapta a ponte privada existente;
- `SystemGestureFrameProvider`: fallback público, com capacidade reduzida;
- `ReplayFrameProvider`: reproduz fixtures JSON nos testes e no laboratório;
- futuramente `SelectedDeviceFrameProvider`: dispositivo explicitamente escolhido.

O serviço de ciclo de vida decide qual provedor usar. O reconhecedor não deve
conhecer `dlopen`, callback C, `NSEvent` ou permissões.

### 4.2 Sessão de contatos

Criar `ContactSessionEngine` para:

- acompanhar cada identificador de dedo;
- produzir transições `down`, `move`, `up` e `cancel`;
- separar dedos âncora de dedos ativos;
- manter posição inicial, atual, velocidade, pressão e duração;
- detectar entrada e saída de dedos sem reiniciar incorretamente a sessão;
- fechar sessões interrompidas por sleep, troca de dispositivo ou perda do callback.

### 4.3 Extração de características

`GestureFeatureExtractor` calcula, sem decidir o gesto:

- centroide e deslocamento;
- distância e ângulo entre contatos;
- expansão e contração;
- rotação acumulada;
- velocidade e aceleração;
- duração e intervalos entre toques;
- trajetória reamostrada;
- pressão absoluta e relativa à calibração;
- região inicial, atual e final;
- borda de entrada e saída;
- dedos apoiados versus dedo que executa a ação.

### 4.4 Reconhecedores especializados

Separar em componentes pequenos:

- `TapSequenceRecognizer`;
- `ChordGestureRecognizer`;
- `DirectionalGestureRecognizer`;
- `PinchRotationRecognizer`;
- `PathTemplateRecognizer`;
- `PressureGestureRecognizer`;
- `ContinuousGestureRecognizer`;
- `GestureSequenceRecognizer`.

Cada reconhecedor devolve candidato, confiança, fase e evidências. Ele não
executa regra nem publica diretamente na UI.

### 4.5 Arbitragem

`GestureArbiter` resolve competições como:

- toque versus início de segurar;
- swipe versus desenho personalizado;
- pinça versus rotação;
- gesto simples versus primeiro passo de uma sequência;
- TipTap versus toque comum com mais dedos.

Regras de arbitragem:

- aguardar apenas quando existir candidato ambíguo;
- favorecer reconhecedor mais específico;
- exigir limiar de confiança;
- emitir no máximo um gesto exclusivo por sessão;
- permitir canais simultâneos somente quando configurados;
- registrar por que candidatos foram aceitos ou rejeitados.

### 4.6 Evento semântico

Introduzir um contrato como:

```swift
struct GestureEvent: Sendable {
    let id: UUID
    let kind: GestureKind
    let phase: GesturePhase
    let fingerCount: Int
    let deviceID: String?
    let startRegion: TrackpadRegion
    let endRegion: TrackpadRegion
    let progress: Double?
    let velocity: Double?
    let pressure: Double?
    let confidence: Double
    let occurredAt: Date
}

enum GesturePhase: String, Codable, Sendable {
    case began
    case changed
    case ended
    case cancelled
}
```

`InputEventDescriptor` continua existindo para teclado, mouse e compatibilidade,
mas passa a carregar uma representação de gesto ou a ser substituído
gradualmente por um `TriggerEvent` comum.

## 5. Evolução do domínio

### 5.1 Especificação do gesto

Substituir os parâmetros soltos do caso `.trackpad` por um valor versionável:

```swift
struct TrackpadTriggerSpec: Codable, Hashable, Sendable {
    var gesture: GestureKind
    var fingerCount: ClosedRange<Int>
    var tapCount: Int
    var startRegion: GestureRegion
    var endRegion: GestureRegion?
    var minimumVelocity: Double?
    var maximumVelocity: Double?
    var pressureThreshold: Double?
    var sensitivity: Double
    var deviceScope: DeviceScope
}
```

Isso evita aumentar indefinidamente a enum `TriggerDefinition` cada vez que um
novo parâmetro for criado.

### 5.2 Condições e perfis

Adicionar condições independentes do gatilho:

```swift
indirect enum RuleCondition: Codable, Hashable, Sendable {
    case frontmostApplication(bundleIdentifiers: Set<String>)
    case windowTitle(matcher: TextMatcher)
    case display(DisplaySelector)
    case modifiers(Set<InputModifier>)
    case timeRange(TimeRange)
    case all([RuleCondition])
    case any([RuleCondition])
    case not(RuleCondition)
}
```

Um perfil passa a ser um agrupamento opcional:

```swift
struct ShortcutProfile: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    var priority: Int
    var conditions: [RuleCondition]
}
```

O `ContextSnapshotService` captura app ativo, janela, display e modificadores
uma vez por evento. `NSWorkspace` fornece o aplicativo ativo. A leitura e
manipulação de janelas ficam em uma ponte estreita baseada em Accessibility.

### 5.3 Fluxo de ações

Evoluir de uma ação única para:

```swift
struct ActionWorkflow: Codable, Hashable, Sendable {
    var steps: [ActionStep]
    var failurePolicy: FailurePolicy
}

struct ActionStep: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var action: ShortcutAction
    var delayBefore: DurationValue?
    var condition: RuleCondition?
}
```

Novas ações:

- aguardar;
- enviar atalho de teclado;
- executar AppleScript;
- executar um Atalho do macOS;
- mover/redimensionar janela;
- maximizar, centralizar e restaurar janela;
- mover janela para display ou Space quando suportado;
- controlar volume;
- controlar brilho quando suportado;
- definir texto no clipboard;
- digitar ou colar texto;
- iniciar outro workflow.

O executor deve suportar cancelamento, timeout, política de erro e log por etapa.

## 6. Roadmap de implementação

## Fase 0 — fundação do motor avançado

**Objetivo:** preparar a arquitetura sem mudar o comportamento visível das
regras existentes.

Entregas:

- `TrackpadFrameProvider`;
- adaptação do bridge atual;
- `ReplayFrameProvider`;
- `ContactSessionEngine`;
- `GestureFeatureExtractor`;
- `GestureEvent` e fases;
- `GestureArbiter`;
- adaptação dos gestos atuais aos novos reconhecedores;
- fixtures gravadas e anonimizadas;
- migração do documento de regras da versão 2 para a versão 3.

Testes:

- replay de todos os gestos existentes;
- entrada e saída irregular de dedos;
- cancelamento, sleep e wake;
- nenhuma emissão para movimento comum com um dedo;
- comparação dos resultados antigos e novos.

Critério de saída:

- todas as regras atuais continuam funcionando;
- nenhum frame bruto chega à main thread para processamento pesado;
- interface recebe atualizações coalescidas;
- fallback público continua disponível.

## Fase 1 — laboratório, calibração e parâmetros avançados

**Objetivo:** tornar o comportamento observável antes de adicionar novos gestos.

Entregas:

- nova janela “Laboratório do Trackpad”;
- visualização em tempo real de contatos, IDs e trajetórias;
- pressão, velocidade, centroide, região e gesto candidato;
- gravação e reprodução de uma sessão;
- controles de sensibilidade;
- velocidade mínima e máxima;
- regiões inicial e final;
- regiões em grade, bordas e cantos;
- presets de sensibilidade: conservador, equilibrado e responsivo;
- diagnóstico de falso positivo.

UI:

- usar `Canvas` SwiftUI para a primeira versão;
- recorrer a um `NSViewRepresentable` somente se a taxa de atualização do
  `Canvas` não for suficiente;
- manter dados e seleção no modelo SwiftUI;
- não guardar `NSWindow` globalmente.

Critério de saída:

- o usuário consegue executar, visualizar e ajustar um gesto sem criar ação;
- uma sessão pode ser exportada para fixture de teste;
- ajustes são persistidos por gesto e opcionalmente por dispositivo.

## Fase 2 — toque múltiplo, acordes e TipTap

**Objetivo:** entregar os gestos avançados de maior retorno.

Entregas:

- toque duplo e triplo com dois a cinco dedos;
- intervalo máximo entre toques configurável;
- dedos âncora apoiados;
- tocar, levantar ou deslizar um dedo enquanto outros permanecem apoiados;
- TipTap esquerdo e direito;
- acordes definidos pela ordem de entrada e saída dos dedos;
- gesto “adicionar dedo” e “remover dedo”;
- representação visual no editor.

Testes:

- jitter de dedos âncora;
- contato acidental adicional;
- troca de identificador durante a sessão;
- toque simples não confundido com início de toque duplo;
- TipTap não confundido com tap de três ou quatro dedos.

Critério de saída:

- TipTap funciona globalmente em cinco aplicativos diferentes;
- taxa de falso positivo aceitável durante navegação normal;
- reconhecedor informa claramente quando o hardware/fallback não suporta o gesto.

## Fase 3 — sequências e combinações

**Objetivo:** permitir uma gramática de gestos sem criar código pelo usuário.

Entregas:

- sequência ordenada de dois a cinco passos;
- intervalo máximo entre passos;
- opção de reiniciar, cancelar ou aceitar prefixo;
- combinação de trackpad, teclado e mouse;
- modo “segurar modificador enquanto faz o gesto”;
- editor visual de passos;
- máquina de estados compilada para cada sequência;
- prevenção de atraso desnecessário em regras simples.

Exemplos:

- swipe para cima e depois direita;
- toque com três dedos seguido de pinça;
- segurar `⌘` e fazer swipe com quatro dedos;
- botão extra do mouse seguido de gesto no trackpad.

Critério de saída:

- sequências sobrepostas têm resultado determinístico;
- prefixos ambíguos são mostrados na detecção de conflitos;
- timeouts não deixam o motor preso em estado intermediário.

## Fase 4 — gestos personalizados graváveis

**Objetivo:** permitir que o usuário ensine trajetórias ao AirShortcut.

Primeira abordagem:

- gravar três a cinco exemplos;
- reamostrar trajetórias para uma quantidade fixa de pontos;
- normalizar translação e escala;
- preservar direção e, opcionalmente, rotação;
- representar centroide, expansão, rotação e contatos;
- comparar por Dynamic Time Warping ou algoritmo equivalente;
- calcular confiança e distância para o segundo melhor candidato;
- rejeitar em vez de adivinhar quando a confiança for baixa.

Entregas:

- assistente de treinamento;
- visualização sobreposta das amostras;
- validação antes de salvar;
- gestos de círculo, “L”, zigue-zague e trajetórias livres;
- opção de gesto com um ou vários dedos;
- regravação e duplicação;
- armazenamento local dos templates;
- exportação junto com presets.

Não usar aprendizado em nuvem na primeira versão. Um reconhecedor determinístico
é mais explicável, testável e compatível com privacidade local.

Critério de saída:

- um template desconhecido é rejeitado;
- templates semelhantes geram aviso de conflito;
- reconhecimento permanece dentro do orçamento de latência;
- amostras antigas continuam decodificando após atualização.

## Fase 5 — perfis, condições e conflitos

**Objetivo:** permitir que o mesmo gesto tenha significado contextual.

Entregas:

- perfil global e perfis por aplicativo;
- seleção do app por painel, sem exigir bundle identifier digitado;
- condição por título de janela;
- display atual;
- modificadores;
- horários;
- prioridade explícita;
- ativação/desativação rápida pela barra de menus;
- simulador “qual regra seria executada agora?”;
- analisador estático de conflitos.

Detecção de conflitos:

- gatilhos idênticos no mesmo contexto;
- condições que se sobrepõem;
- sequência que contém outra sequência como prefixo;
- gesto personalizado semelhante;
- ação contínua competindo com ação discreta;
- regra global escondendo regra específica por prioridade.

Critério de saída:

- o avaliador recebe um único `ContextSnapshot` por evento;
- regras específicas vencem regras globais conforme política documentada;
- o editor explica o conflito e oferece correção.

## Fase 6 — workflows, Atalhos e automações

**Objetivo:** transformar uma regra em uma automação composta.

Entregas:

- editor de passos;
- atraso entre passos;
- continuar, parar ou desfazer parcialmente após erro;
- atalhos de teclado simulados;
- clipboard;
- AppleScript;
- integração com Atalhos do macOS;
- reutilização de workflows;
- log por etapa;
- timeout e cancelamento;
- confirmação resumida para workflows importados ou perigosos.

Segurança:

- mostrar comando, AppleScript e parâmetros antes da primeira execução;
- manter aprovação associada ao conteúdo exato;
- invalidar aprovação quando o workflow mudar;
- nunca importar um workflow perigoso já marcado como aprovado;
- registrar saída truncada e código de encerramento sem armazenar segredos.

Critério de saída:

- workflow interrompido não continua em background inesperadamente;
- erros identificam exatamente a etapa;
- scripts e AppleScript obedecem à política de aprovação.

## Fase 7 — automação de janelas e ações contínuas

**Objetivo:** fazer o gesto controlar algo durante seu movimento.

Entregas de janela:

- obter janela focada via Accessibility;
- salvar frame original;
- centralizar, maximizar e restaurar;
- metades, terços, quartos e grade configurável;
- mover e redimensionar proporcionalmente ao gesto;
- mover para outro monitor;
- respeitar `visibleFrame`, menu bar e Dock;
- tratar apps que não permitem alterar posição ou tamanho.

Entregas contínuas:

- contrato `ContinuousActionSession`;
- `begin`, `update`, `commit` e `cancel`;
- mapeamento de distância/rotação para valor;
- curva linear, acelerada e precisa;
- volume e brilho quando a capacidade estiver disponível;
- tamanho e posição de janela;
- feedback visual opcional;
- coalescimento para não executar uma ação por frame bruto.

Ponte AppKit/Accessibility:

- `WindowAutomationService` é o único proprietário de `AXUIElement`;
- SwiftUI envia comandos e recebe resultados;
- nenhum `AXUIElement` é persistido;
- referências são revalidadas antes de cada alteração;
- timeout curto evita travar quando outro app não responde.

Critério de saída:

- cancelar o gesto restaura o estado quando a ação for reversível;
- atualizações não congestionam a main thread;
- falhas de Accessibility não derrubam a captura.

## Fase 8 — pressão, Force Touch e múltiplos dispositivos

**Objetivo:** explorar capacidades dependentes do hardware sem degradar outros Macs.

Pressão:

- detectar faixa real observada por dispositivo;
- calibrar repouso, toque e pressão forte;
- expor limiar simples e faixa contínua;
- combinar pressão com tap, hold e swipe;
- ignorar pressão quando o dispositivo não fornecer dados confiáveis.

Dispositivos:

- spike separado para enumerar trackpads compatíveis;
- identificador estável quando a ABI permitir;
- interno, Magic Trackpad e “qualquer dispositivo”;
- calibração e sensibilidade por dispositivo;
- reconexão;
- migração segura quando um dispositivo desaparece.

Risco:

O bridge atual usa o dispositivo padrão. Enumeração e identidade dependem de
símbolos privados adicionais e precisam de uma decisão go/no-go após o spike.
Se a identidade não for estável, a UI deve oferecer apenas “padrão” e “qualquer”.

Critério de saída:

- recursos não suportados ficam ocultos ou explicados;
- desconectar o trackpad não trava o app;
- regra por dispositivo possui fallback configurável.

## Fase 9 — presets, métricas e acabamento de produto

**Objetivo:** tornar a configuração compartilhável e sustentável.

Entregas:

- pacotes de presets versionados;
- visualização antes da importação;
- detecção de IDs, ações perigosas e conflitos;
- exportação seletiva;
- biblioteca local de presets;
- histórico por gesto e regra;
- sucesso, rejeição, confiança e latência;
- dados de diagnóstico opt-in e locais por padrão;
- filtros e exportação do histórico;
- assistente de compatibilidade após atualização do macOS;
- backup antes de migração;
- recuperação de documento inválido.

Armazenamento:

- regras, perfis, workflows e templates continuam em documentos versionados;
- histórico de alto volume deve migrar para SQLite;
- frames brutos não são persistidos por padrão;
- sessões do laboratório precisam de ação explícita para serem salvas.

Critério de saída:

- importar nunca executa uma ação;
- usuário revisa diferenças antes de confirmar;
- histórico permanece limitado e não aumenta indefinidamente.

## Fase 10 — supressão do evento original

**Objetivo:** investigar bloqueio somente onde houver garantia técnica e UX segura.

Escopo possível:

- teclado e mouse podem usar `CGEventTap` como filtro ativo;
- oferecer supressão por regra, nunca global por padrão;
- incluir combinação de emergência para pausar captura;
- reativar event tap desabilitado pelo sistema;
- impedir que uma regra suprima a própria forma de recuperação.

Limitação:

O callback bruto de `MultitouchSupport` é observacional. Ele não garante que um
gesto reservado do macOS possa ser cancelado. Portanto:

- não prometer supressão de gesto de trackpad antes de um protótipo provar isso;
- não alterar preferências globais do usuário como atalho para “bloquear” gestos;
- não instalar driver ou extensão de kernel para essa finalidade;
- manter a ação original quando a supressão não for comprovadamente segura.

Gate de decisão:

1. protótipo isolado;
2. teste em todas as versões suportadas do macOS;
3. mecanismo de recuperação;
4. análise de permissões e distribuição;
5. somente então expor a opção no editor.

## 7. Migrações planejadas

### Documento de regras v3

- introduzir `TrackpadTriggerSpec`;
- migrar gesto, quantidade de dedos e região atuais;
- valores antigos preservam comportamento exato.

### Documento de regras v4

- adicionar perfis e condições;
- transformar ação única em workflow de uma etapa;
- regra sem perfil permanece global.

### Documento de regras v5

- templates personalizados;
- escopo de dispositivo;
- parâmetros contínuos;
- referências a presets.

Cada migração deve:

- decodificar a versão anterior;
- produzir backup antes de gravar;
- ser idempotente;
- possuir fixtures de todas as versões;
- rejeitar versão futura sem sobrescrever o arquivo.

## 8. Estratégia de testes

### Unitários

- sessão e ciclo de vida de contatos;
- extração de características;
- reconhecedor individual;
- arbitragem;
- sequências e timeouts com relógio injetável;
- comparação de templates;
- condições e prioridade;
- análise de conflitos;
- workflow, cancelamento e políticas de erro;
- migrações.

### Replay

Manter biblioteca de fixtures:

- gestos válidos lentos e rápidos;
- jitter;
- dedo adicional acidental;
- gesto incompleto;
- troca de quantidade de dedos;
- palm rejection;
- sleep e wake;
- desconexão;
- gestos semelhantes que devem ser rejeitados.

### Integração

- provedor privado para motor de sessões;
- contexto de app ativo;
- janela focada e Accessibility;
- workflows com serviços falsos;
- importação e exportação;
- fallback público.

### Hardware

- trackpad interno;
- Magic Trackpad, quando disponível;
- cada versão de macOS suportada;
- diferentes configurações de velocidade do sistema;
- gestos do macOS ativados e desativados;
- monitor único e múltiplos monitores.

### Metas não funcionais

- captura nunca bloqueia a main thread;
- UI recebe no máximo a taxa necessária para desenhar;
- gesto discreto é emitido apenas uma vez;
- ação contínua é coalescida;
- nenhum crash após sleep, wake ou desconexão;
- falso positivo é medido por cenário, não apenas por testes felizes;
- logs não armazenam texto sensível de janelas por padrão.

## 9. Ordem, dependências e esforço relativo

| Fase | Depende de | Esforço | Risco |
|---|---|---:|---:|
| 0. Fundação | base atual | alto | alto |
| 1. Laboratório | fase 0 | médio | baixo |
| 2. TipTap e taps | fases 0–1 | alto | médio |
| 3. Sequências | fase 2 | médio | médio |
| 4. Personalizados | fases 0–1 | alto | alto |
| 5. Perfis e conflitos | domínio v3 | alto | médio |
| 6. Workflows | condições v4 | alto | médio |
| 7. Janelas/contínuo | fases 0, 5 e 6 | alto | alto |
| 8. Pressão/dispositivos | fases 0–1 | alto | muito alto |
| 9. Presets/métricas | fases 4–6 | médio | médio |
| 10. Supressão | captura estável | spike | muito alto |

Para uma pessoa desenvolvendo e validando em hardware, o programa completo deve
ser tratado como aproximadamente quatro a seis meses de trabalho concentrado,
não como uma única entrega. A API privada e a matriz de hardware podem aumentar
esse prazo.

## 10. Sequência recomendada de releases

### Release A — Motor 2.0

- fase 0;
- laboratório básico;
- comportamento atual preservado.

### Release B — Gestos avançados

- toque duplo/triplo;
- TipTap;
- acordes;
- sensibilidade e regiões avançadas.

### Release C — Gramática

- sequências;
- modificadores;
- conflitos.

### Release D — Gestos ensináveis

- templates personalizados;
- treinamento;
- presets.

### Release E — Contexto e automação

- perfis;
- condições;
- workflows;
- Atalhos e AppleScript.

### Release F — Controle direto

- automação de janelas;
- ações contínuas;
- volume e brilho compatíveis.

### Release G — Hardware e acabamento

- pressão;
- dispositivos;
- métricas;
- compatibilidade e recuperação.

### Release experimental

- filtro ativo para teclado/mouse;
- pesquisa de supressão de gestos do trackpad.

## 11. Primeiro lote executável

O primeiro lote deve ser fechado antes de iniciar funcionalidades paralelas:

1. criar `TrackpadFrameProvider`;
2. mover o callback privado para o provedor;
3. implementar `ReplayFrameProvider`;
4. criar `ContactSessionEngine`;
5. extrair características sem classificação;
6. introduzir `GestureEvent` com fases;
7. portar tap, hold, swipe, pinch e rotação;
8. adicionar arbitragem;
9. criar fixtures de replay;
10. migrar regras para `TrackpadTriggerSpec`;
11. construir o laboratório mínimo;
12. validar em hardware e confirmar que não houve regressão.

Somente depois disso devem começar TipTap, sequências e templates. Essa ordem
evita que cada nova funcionalidade crie mais estado dentro do reconhecedor atual
e reduz o risco de falsos positivos difíceis de reproduzir.

## 12. Fontes técnicas

- Apple, `NSWorkspace.frontmostApplication`:
  https://developer.apple.com/documentation/appkit/nsworkspace/frontmostapplication
- Apple, notificação de aplicativo ativado:
  https://developer.apple.com/documentation/appkit/nsworkspace/didactivateapplicationnotification
- Apple, `AXUIElement`:
  https://developer.apple.com/documentation/applicationservices/axuielement_h
- Apple, opções de `CGEventTap`:
  https://developer.apple.com/documentation/coregraphics/cgeventtapoptions
- Apple, criação de `CGEventTap`:
  https://developer.apple.com/documentation/coregraphics/cgevent/tapcreate(tap:place:options:eventsofinterest:callback:userinfo:)
- OpenMultitouchSupport:
  https://github.com/Kyome22/OpenMultitouchSupport

