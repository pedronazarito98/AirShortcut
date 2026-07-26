# Arquitetura do Tico

O Tico é um aplicativo nativo para macOS 14+, feito em SwiftUI e organizado
como um pacote SwiftPM. `Tico` é o nome público; produto, target e executável
continuam chamados `AirShortcut` para preservar dados e permissões existentes.

## Camadas

- **Modelos:** regras, gatilhos, gestos, perfis, workflows e ações.
- **Armazenamentos:** persistência versionada, calibração, métricas e logs.
- **Serviços:** permissões, captura, reconhecimento, contexto e execução.
- **Bridge do trackpad:** fronteira C pequena que carrega
  `MultitouchSupport` dinamicamente.
- **Interface:** telas SwiftUI, Laboratório e item da barra de menus.

## Fluxo de uma entrada

1. O app verifica Monitoramento de Entrada e Acessibilidade quando necessário.
2. Teclado e mouse são normalizados em `InputEventDescriptor`.
3. O trackpad usa captura privada ou fallback público.
4. Frames viram sessões, características e candidatos de gesto fora da thread
   principal.
5. O motor escolhe o gesto e avalia contexto, sequência, prioridade e
   conflitos.
6. A ação só é executada depois que uma regra compatível é encontrada.

Replay usa o mesmo motor de reconhecimento, mas fica isolado do executor de
ações. Ele pode atualizar o Laboratório e os diagnósticos sem disparar regras.

## Compatibilidade

- Bundle público: `Tico.app`.
- Artefato: `Tico.zip`.
- Executável: `AirShortcut`.
- Bundle identifier: `com.pedronazarito.AirShortcut`.
- Dados: `Application Support/AirShortcut`.
- Preferências: chaves legadas `com.airshortcut.*`.

Esses nomes técnicos não devem ser alterados sem uma migração própria, com
cópia atômica, validação e rollback.
