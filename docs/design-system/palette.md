# Palette ASCII

Pipeline: `char` → `PaletteEntry { char ch; sf::Color color; BodyPartId part }` → textura via `makeSprite`.

## Player Palette exemplo
| ch | color | BodyPartId |
|----|-------|------------|
| '.' | 0,0,0,0 | None |
| 'K' | 30,20,20 | None |
| 'F' | 230,180,140 | Head |
| 'H' | 230,180,140 | ArmR |
| 'E' | 20,15,15 | Head |
| 'C' | 60,90,160 | Torso |
| 'B' | 50,35,30 | LegR |
| 'W' | 190,190,200 | Weapon |
| 'T' | 220,60,50 | Weapon |
| 't' | 90,30,25 | Weapon |

## Regras
- Um caractere = um pixel.
- Linhas devem ter exatamente `w` chars.
- `part = None` → só visual.
- `part != None` → hitbox derivada em `rebuildFromSprite`.
