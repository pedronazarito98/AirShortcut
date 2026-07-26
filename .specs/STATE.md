# STATE

## Decisions

### AD-001

- **Decision**: A iniciativa atual trata prontidão para release e validação do AirShortcut existente; novas famílias de gestos ficam fora deste ciclo.
- **Reason**: A implementação principal e a auditoria de segurança já existem; o risco restante é evidência operacional, compatibilidade física e distribuição.
- **Trade-off**: O produto não ampliará seu escopo funcional enquanto a matriz de validação e os gates de release não estiverem fechados.
- **Scope**: Todas as tarefas da iniciativa `release-readiness`.
- **Date**: 2026-07-26
- **Status**: active

### AD-002

- **Decision**: Testes automatizados cobrem domínio, persistência, replay, segurança e empacotamento; comportamento real do trackpad exige evidência manual versionada.
- **Reason**: Replay é determinístico e seguro para CI, mas não prova ABI privada, TCC, sleep/wake, reconexão ou falso positivo em uso normal.
- **Trade-off**: A aprovação final pode depender de uma sessão humana com hardware compatível.
- **Scope**: Pipeline CI, checklist de QA, relatório de hardware e gate final.
- **Date**: 2026-07-26
- **Status**: active

### AD-003

- **Decision**: A distribuição alvo é direta, fora da Mac App Store, com Developer ID e notarização; o build ad hoc permanece somente para desenvolvimento.
- **Reason**: A captura avançada carrega dinamicamente o framework privado `MultitouchSupport` e o app não é compatível com o modelo convencional da App Store.
- **Trade-off**: A publicação exige identidade Apple, Hardened Runtime e validação adicional em máquina limpa.
- **Scope**: Scripts de release, documentação e checklist de distribuição.
- **Date**: 2026-07-26
- **Status**: active

### AD-004

- **Decision**: Evidências commitadas no repositório não conterão identificadores de dispositivo, gravações pessoais brutas, credenciais ou dados de TCC.
- **Reason**: O laboratório pode observar contatos e dispositivos locais; o repositório é público.
- **Trade-off**: O relatório público será um resumo sanitizado, enquanto detalhes locais permanecem fora do Git.
- **Scope**: Templates de QA, relatórios, fixtures e release notes.
- **Date**: 2026-07-26
- **Status**: active

## Handoff

- **Feature**: `.specs/features/release-readiness/`
- **Phase / Task**: Specify → Design → Tasks concluídos; aguardando aprovação para Execute.
- **Completed**: Especificação, contexto, design e decomposição inicial.
- **In-progress**: Nenhum código de produto alterado; somente artefatos de planejamento serão criados nesta etapa.
- **Next step**: Revisar e aprovar os artefatos; depois executar as fases em lotes sequenciais conforme `tasks.md`.
- **Blockers**: A matriz física final exige acesso ao trackpad interno e, idealmente, a um Magic Trackpad.
- **Uncommitted files**: `.specs/STATE.md`, `.specs/features/release-readiness/`
- **Branch**: `main`
