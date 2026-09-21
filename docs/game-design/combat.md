# Game Design - Combate

## Conceito
Combate baseado em anatomia per-part. O jogador sente diferença ao mirar cabeça vs torso vs braço.

## Sistemas
- `MeleeSystem` prioridade 300
- `ContactDamageSystem` prioridade 310
- `ExplosionSystem` prioridade 320
- `DeathSystem` prioridade 330

## Per-Part
`BodySchema` com `PartDef { id, offset, size, damageMult, postureMult, breakable }`

Multiplicadores padrão humanoid:
- Head: damageMult 2.0, postureMult 1.5
- Torso: 1.0 / 1.0
- ArmL/ArmR: 0.6 / 0.5, breakable
- LegL/LegR: 0.7 / 0.8, breakable
- Weapon: 1.0

## Regras
- Broadphase AABB do corpo antes de narrowphase por parte.
- Melhor parte tocada define multiplicadores.
- Sem schema → fallback AABB cru 1x
- Com schema e nenhuma parte tocada → whiff, sem dano
- Dedup por swing via `lastHitSwing`

## Feedback
- Hit spark via `ParticleSystem`
- Posture quebra ao atingir threshold
