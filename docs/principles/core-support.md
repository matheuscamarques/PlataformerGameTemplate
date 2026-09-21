# Principles - Core Support

## Regras
1. `core/` não depende de `support/`.
2. `support/` pode depender de `core/`.
3. `defines.h` é shim para `core/Config.h` e `core/EntityKind.h`.

## Motivo
Permite testar camadas isoladamente, evita ciclos, mantém primitives estáveis.

## Verificação
`make test-layers` executa:
`! grep -rn '#include.*support/' src/core/`
