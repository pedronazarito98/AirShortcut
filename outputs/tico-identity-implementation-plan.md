# Plano de implementação da identidade Tico

## Objetivo

Aplicar a identidade visual aprovada do Tico ao app macOS sem perder regras,
preferências, métricas, logs ou permissões já concedidas ao AirShortcut.

## Decisão de compatibilidade

Nesta primeira migração, **Tico será o nome público** e **AirShortcut continuará
como identidade técnica interna**.

Permanecem iguais:

- módulo, target e produto SwiftPM: `AirShortcut`;
- executável interno: `AirShortcut`;
- bundle identifier: `com.pedronazarito.AirShortcut`;
- pastas existentes em `Application Support/AirShortcut`;
- chaves de `UserDefaults`;
- nomes internos de notificações, filas e subsistemas de log;
- formato e versão dos documentos de regras.

Mudam:

- nome exibido no Finder, Dock, janelas e menus: `Tico`;
- ícone do app e símbolo da barra de menus;
- cores e elementos visuais da interface;
- textos voltados ao usuário;
- nome do `.app`, do `.zip` e dos arquivos exportados.

Essa separação evita que a troca de marca faça o macOS tratar o Tico como um app
novo e reduz o risco de perder permissões de Acessibilidade e Monitoramento de
Entrada.

## Dependências entre as fases

```text
Assets finais
    ↓
Tokens e componente de marca
    ↓
Nome e textos visíveis
    ↓
Empacotamento Tico.app
    ↓
Migração/compatibilidade
    ↓
QA visual, testes e distribuição
```

## Fase 1 — Produzir os assets finais

### Trabalho

1. Transformar o símbolo aprovado em um master limpo, com geometria única.
2. Exportar:
   - símbolo colorido para fundos claros;
   - símbolo colorido para fundos escuros;
   - símbolo monocromático/template para a barra de menus;
   - wordmark horizontal claro e escuro;
   - ícone master quadrado de `1024 × 1024`;
   - `.icns` compatível com macOS 14+.
3. Manter as fontes editáveis/master separadas dos arquivos gerados.
4. Criar `Sources/AirShortcut/Resources/Brand/` para os assets usados em runtime.
5. Adicionar os resources do target em `Package.swift`.

### Arquivos

- `Design/Brand/Tico/`
- `Sources/AirShortcut/Resources/Brand/`
- `Package.swift`

### Verificação

- O símbolo continua legível em 16, 24, 32, 64, 128, 256, 512 e 1024 px.
- O ícone tem margem segura e não traz cantos arredondados pré-recortados.
- As versões clara, escura e monocromática usam a mesma geometria.
- O `.icns` pode ser lido por `iconutil` e contém as escalas necessárias.

### Observação de plataforma

O pacote atual é um app SwiftPM montado manualmente e suporta macOS 14. A
primeira entrega deve usar um `.icns` universal no bundle. Variantes modernas
de ícone criadas com Icon Composer podem ser uma evolução posterior para
sistemas mais novos; elas não devem bloquear o rebranding compatível.

## Fase 2 — Criar o sistema de marca no código

### Trabalho

1. Criar uma fonte única de verdade, por exemplo `Support/TicoBrand.swift`, com:
   - `displayName = "Tico"`;
   - nomes de exportação;
   - referências aos assets;
   - nomes técnicos legados explicitamente documentados.
2. Criar tokens adaptativos:
   - light: `#F8F7FC`, `#FFFFFF`, `#6366F1`, `#FF6B6B`,
     `#111827`, `#5B6475`;
   - dark: `#0B1220`, `#151E2E`, `#7C8CFF`, `#FF7A72`,
     `#F3F5FA`, `#AAB3C2`.
3. Expor os tokens como estilos semânticos, por exemplo:
   `brandPrimary`, `brandAccent`, `brandBackground`,
   `brandSurface`, `brandText` e `brandSecondaryText`.
4. Criar um componente pequeno e reutilizável para o símbolo/wordmark.
5. Preservar cores semânticas do sistema para sucesso, alerta e erro. Roxo e
   coral não devem substituir verde, laranja ou vermelho nesses estados.

### Arquivos prováveis

- `Sources/AirShortcut/Support/TicoBrand.swift`
- `Sources/AirShortcut/Views/Components/TicoMarkView.swift`
- `Sources/AirShortcut/Resources/Brand/`
- `Package.swift`

### Verificação

- Trocar a aparência do macOS atualiza os tokens sem reiniciar o app.
- Texto e controles mantêm contraste legível nos dois modos.
- A marca aparece corretamente com Aumentar Contraste e Reduzir Transparência.
- Nenhuma view precisa conhecer valores hexadecimais diretamente.

## Fase 3 — Aplicar a marca pública

### Trabalho

1. Substituir textos visíveis de `AirShortcut` por `Tico`:
   - título da janela;
   - navegação lateral;
   - barra de menus;
   - permissões e mensagens de recuperação;
   - alertas;
   - importação/exportação;
   - exemplos e notificações exibidas ao usuário.
2. Alterar o label do `MenuBarExtra` e usar o símbolo monocromático como
   template, mantendo uma indicação discreta do estado de captura.
3. Aplicar a cor primária aos elementos de ação e seleção.
4. Usar coral apenas em pequenos pontos de energia/ênfase da marca.
5. Atualizar o nome padrão de exportação para `Tico-rules.json`.
6. Manter nomes internos como `AirShortcutSection`,
   `Notification.airShortcut...` e subsistemas de log nesta fase.

### Arquivos principais

- `Sources/AirShortcut/App/AirShortcutApp.swift`
- `Sources/AirShortcut/Views/SidebarView.swift`
- `Sources/AirShortcut/Views/MenuBarContentView.swift`
- `Sources/AirShortcut/Views/PermissionsView.swift`
- `Sources/AirShortcut/Views/OverviewView.swift`
- `Sources/AirShortcut/Views/ContentView.swift`
- `Sources/AirShortcut/Views/RuleActionEditorView.swift`
- `Sources/AirShortcut/Support/RuleFilePanel.swift`
- `Sources/AirShortcut/Services/WindowControlService.swift`
- `Sources/AirShortcut/Support/AppController.swift`

### Verificação

- Uma busca por `AirShortcut` nos textos visíveis não encontra marca antiga.
- Os nomes internos preservados estão identificados como compatibilidade.
- Menu principal, Menu Bar Extra, alertas e notificações exibem `Tico`.
- Light e dark mode apresentam a mesma hierarquia, sem cores estouradas.

## Fase 4 — Empacotar como Tico.app

### Trabalho

1. Separar no script:
   - produto SwiftPM: `AirShortcut`;
   - executável: `AirShortcut`;
   - nome público/bundle: `Tico`;
   - bundle identifier estável: `com.pedronazarito.AirShortcut`.
2. Gerar:
   - `dist/Tico.app`;
   - `dist/Tico.zip`;
   - `Tico.app/Contents/MacOS/AirShortcut`.
3. Adicionar `CFBundleIconFile` ao `Info.plist`.
4. Copiar o `.icns` e resources SwiftPM para `Contents/Resources`.
5. Definir `CFBundleName` e `CFBundleDisplayName` como `Tico`.
6. Manter a assinatura com o bundle identifier atual e o requisito designado
   já usado no desenvolvimento.
7. Adaptar `pkill`, `pgrep` e predicados de log ao nome real do executável,
   não ao nome do bundle.

### Arquivos

- `script/build_and_run.sh`
- `outputs/qa-checklist.md`
- `outputs/signing-and-distribution.md`

### Verificação

- `plutil -lint dist/Tico.app/Contents/Info.plist`.
- `CFBundleDisplayName` retorna `Tico`.
- `CFBundleExecutable` retorna `AirShortcut`.
- `CFBundleIdentifier` continua `com.pedronazarito.AirShortcut`.
- O Finder, Dock e Ajustes do Sistema exibem nome e ícone novos.
- O app abre pelos modos `run`, `--verify`, `--laboratory-verify` e
  `--fallback-diagnostic`.

## Fase 5 — Garantir dados e permissões existentes

### Trabalho

1. Manter `Application Support/AirShortcut` como diretório canônico.
2. Centralizar esse nome como `legacyApplicationSupportDirectoryName`, para
   evitar que uma futura limpeza de nomes quebre os dados.
3. Não alterar a versão do documento de regras, porque o schema não muda.
4. Manter bundle ID e requisito designado durante a transição.
5. Testar uma instalação simulada com regras, perfis, gestos personalizados,
   logs e métricas já existentes.
6. Documentar que a migração física para `Application Support/Tico`, se um dia
   for desejada, precisa de uma fase própria com cópia atômica, rollback e
   fallback para a pasta antiga.

### Arquivos principais

- `Sources/AirShortcut/Stores/ShortcutStore.swift`
- `Sources/AirShortcut/Stores/EventLogStore.swift`
- `Sources/AirShortcut/Stores/MetricsStore.swift`
- `Sources/AirShortcut/Stores/AppSettingsStore.swift`
- testes dos stores e de permissões

### Verificação

- Uma fixture criada como AirShortcut abre no Tico sem migração destrutiva.
- Regras, perfis, workflows e gestos customizados permanecem intactos.
- Preferências do `UserDefaults` continuam disponíveis.
- Permissões existentes não são solicitadas novamente no cenário de upgrade
  com a mesma assinatura.

## Fase 6 — Testes e QA visual

### Testes automatizados

1. Adicionar testes para `TicoBrand` e nomes públicos.
2. Testar que os caminhos de dados continuam apontando para
   `Application Support/AirShortcut`.
3. Testar importação de documentos anteriores.
4. Testar o script de empacotamento e as chaves do `Info.plist`.
5. Executar a suíte SwiftPM completa.

### QA manual

1. Abrir cada tela em light e dark mode.
2. Conferir:
   - visão geral;
   - regras e editor;
   - perfis;
   - biblioteca de gestos;
   - laboratório;
   - permissões;
   - métricas;
   - log;
   - configurações;
   - Menu Bar Extra;
   - alertas e notificações.
3. Validar Aumentar Contraste, Reduzir Transparência e tamanhos de texto.
4. Conferir o ícone no Finder, Dock, Spotlight e Ajustes do Sistema.
5. Validar captura física no trackpad sem regressão.

### Comandos de validação

```sh
swift test --disable-sandbox
./script/build_and_run.sh --package
plutil -lint dist/Tico.app/Contents/Info.plist
```

Depois, extrair `dist/Tico.zip` em um diretório limpo sob `/private/tmp`,
executar `xattr -cr` e validar:

```sh
codesign --verify --deep --strict Tico.app
```

## Critérios de aceite

- O produto aparece para o usuário como `Tico` em todos os pontos relevantes.
- O app possui ícone oficial e símbolo próprio na barra de menus.
- A interface respeita light e dark mode com os tokens aprovados.
- O bundle ID e o executável técnico continuam estáveis.
- Nenhuma regra, preferência, métrica, log ou gesto personalizado é perdido.
- Permissões existentes permanecem válidas no cenário de atualização.
- A suíte completa passa sem regressões.
- `Tico.zip` contém um app assinado e verificável após extração limpa.
- A documentação de build e QA usa os novos nomes corretamente.

## Ordem recomendada de entrega

1. **Marco A — Assets aprovados:** masters, exports e `.icns`.
2. **Marco B — Marca no runtime:** tokens, componente e textos públicos.
3. **Marco C — Bundle Tico:** `Tico.app` e `Tico.zip` mantendo identidade
   técnica.
4. **Marco D — Compatibilidade comprovada:** dados e permissões existentes.
5. **Marco E — Release candidate:** suíte, QA visual, hardware, assinatura e
   documentação concluídos.

## Fora do escopo desta primeira migração

- Renomear target, módulo, imports e testes SwiftPM.
- Trocar o bundle identifier.
- Mover automaticamente os dados para `Application Support/Tico`.
- Alterar schema ou versão dos documentos de regras.
- Migrar o build inteiro para um projeto Xcode.
- Exigir recursos exclusivos das versões mais novas do macOS.
