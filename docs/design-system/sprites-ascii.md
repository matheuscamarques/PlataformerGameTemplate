# Sprites ASCII

## Estrutura
Arquivo de sprite definido por:
- `kWidth`, `kHeight`
- `PaletteEntry[]`
- `const char* const rows[]`

## Convenções
- Topo compartilhado via macros, teste trava widths.
- Animação por troca de `rows` set: Idle, WalkA, WalkB, Jump, Throw, Punch, Hurt, Death.
- Facing é aplicado em runtime por espelhamento lógico em `Body::rebuildFromSprite`.

## Exemplo
`kPlayerIdle[20]` 12x20 chars.
Hitbox por parte é derivada por varredura de pixels do caractere.

## Boas práticas
- Manter proporções do sprite consistentes com AABB.
- Usar caractere transparente '.' para áreas vazias.
- Separar visual de hitbox via palette `part`.
