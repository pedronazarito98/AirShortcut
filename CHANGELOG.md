# Changelog

## Unreleased — technical preview

Baseline desta iniciativa: `27e0650`. Estado de readiness avaliado em
`1b7785c`.

### Incluído

- gate macOS compartilhado para build, 100 testes Swift, 8 regressões de
  segurança e verificação do package ad hoc;
- documentação pública de status, segurança, captura privada, fallback
  público e replay isolado;
- pacote sanitizado para evidência física e validador de relatório;
- preflight que extrai o ZIP em diretório temporário e executa
  `codesign --verify --deep --strict`;
- templates e checklists de evidência para uma futura distribuição Developer
  ID.

### Estado verificado

- Build/test/package local: PASS.
- Replay 0.5×, 1× e 2× sem execução de ações: PASS automatizado.
- Trackpad físico interno e Magic Trackpad: NOT-RUN.
- Fallback, permission denied, sleep/wake, reconexão e falsos positivos em
  hardware real: NOT-RUN.
- Assinatura do ZIP local: ad hoc/development.
- Developer ID, Hardened Runtime de distribuição, notarização, staple,
  Gatekeeper e máquina limpa: BLOCKED/NOT-RUN.
- Licença open source: BLOCKED aguardando decisão do proprietário.

### Limitações

- A captura avançada usa o framework privado `MultitouchSupport` e deve ser
  revalidada por versão do macOS e classe de dispositivo.
- O fallback público tem capacidades diferentes da captura privada.
- O ZIP ad hoc é apenas um dry-run local e não deve ser distribuído como
  release para usuários.
- A publicação do código como technical preview não representa suporte físico
  nem aprovação de distribuição.

### Como verificar

```bash
./script/ci_verify.sh --package
./script/release_preflight.sh dist/AirShortcut.zip
./script/validate_hardware_report.sh outputs/hardware-validation/report-2026-07-26.md
```

Consulte `outputs/release-readiness-checklist.md` para o mapa RR-01–RR-14 e
`outputs/follow-up-issues.md` para os gaps ainda abertos.
