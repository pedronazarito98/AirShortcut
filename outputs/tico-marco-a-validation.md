# Tico — validação do Marco A

Data: 2026-07-26

## Resultado

Marco A concluído.

## Assets entregues

- símbolo light e dark em PNG RGBA de `1024 × 1024`;
- símbolo monocromático preto e branco;
- wordmark light e dark com Sora SemiBold;
- símbolo template para menu bar em `18 × 18` e `36 × 36`;
- ícone master de `1024 × 1024`;
- iconset com 10 arquivos entre 16 e 1024 px;
- `Tico.icns`;
- fonte Sora variável e licença OFL junto aos masters;
- script reproduzível de geração dos exports.

## Validações

- PNGs abrem corretamente e possuem as dimensões esperadas.
- Símbolos transparentes têm cantos com alpha zero.
- Não há contaminação do chroma key verde nos exports finais.
- As cores dominantes correspondem aos tokens light e dark aprovados.
- O `.icns` é reconhecido como `Mac OS X icon`.
- `iconutil` consegue extrair o conteúdo do `.icns`.
- O target SwiftPM copia os sete resources de runtime para
  `AirShortcut_AirShortcut.bundle`.
- `git diff --check` não encontrou erros de whitespace.
- `swift test --disable-sandbox`: 97 testes executados, 0 falhas.

## Limite desta fase

No encerramento do Marco A, o target SwiftPM já produzia o resource bundle, mas
o script que monta o `.app` ainda não o copiava. O Marco B adicionou a cópia
para `Contents/Resources`, necessária para renderizar a marca no runtime.
Referenciar `Tico.icns` no `Info.plist` continua pertencendo à fase de
empacotamento do plano.
