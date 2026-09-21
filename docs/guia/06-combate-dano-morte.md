# 06 — Combate, dano e morte: melee, contato, explosão, Body per-part

## A ordem importa (prioridades)

No original (`scheduler`, banda `300–399` combate, depois da física `200–299`):

`Melee 300 → Contact 310 → Explosion 320 → Death 330 → Particle 350`

Por que: melee move hitbox na física; contato verifica sobreposição já resolvida; explosão quebra tiles e aplica dano em área; morte limpa e dispara drops/partículas. Inverter (morte antes do dano) perde kill.

Para seu jogo: mantenha `Melee < Contact < Death` mesmo que só tenha soco e encostão.

## Melee (o ataque principal)

`src/support/Combat/MeleeSystem.*` no original:

- `pressed(Heavy) → player->startSwing()`; `updateMelee(dt)` retorna fase; só na fase `Active` a `meleeHitbox()` é válida (`box.width > 0`).
- Dano base por combo `8/10/16`, `AimDir` 8 vias + `swingAim` snapshot (mira congela no início).
- Dedup por swing: `if (s.lastHitSwing == player->meleeSwingId) return;` — sem isso, 1 swing dá N hits em N ticks.
- Whiff: com schema e nenhuma parte tocada → sem dano (não AABB cheio).
- Hit spark via `ParticleSystem` no ponto médio do corpo.

Mínimo para seu jogo: `pressed → hitbox retângulo à frente por X ms → 1 hit por swing → dano fixo`. Adicione combo e mira depois.

## ContactDamage (o encostão)

Prio `310`, `10 dmg` no original. Verifica sobreposição `player ↔ inimigo` fora do melee. É o que faz slime parado ser perigoso. Sem ele, player abraça slime sem consequência.

## Explosion e Throw (área + projétil)

- `ThrowSystem` (prio `220`, pool `64`): `Dynamite` com fuse + `grav 600`, `Spit/Barrel`. `tryThrow()` com `throwCooldown 0.5s`, `dynamite 999`.
- `ExplosionSystem` (prio `320`): `r 40px / dmg 25 / posture 20 / tiles 3 / knock 250`. Quebra tiles em círculo (`breakTilesInCircle`) e aplica dano **per-part** (cabeça `2x`, braço `0.6x`).
- `WeaponRegistry`: `sword (16x8, phased) / axe (8x20, idle-only)`. Comece com 1 arma fixa; registro só quando tiver 3+.

## Death (limpeza + recompensa)

Prio `330`: apaga morto (`erase`), chama `onDeath` → `DropSystem` + `ParticleSystem`. Sem ele, corpo fica no chão bloqueando ou some sem drop.

## Body per-part (mirar na cabeça dói mais)

`BodySchema` / `PartDef { id, offset, size, damageMult, postureMult, breakable }` / `Body::rebuildFromSprite()` (prio `250`):

- `humanoid(h=24, w=12)`: Head `2.0/1.5`, Torso `1.0/1.0`, ArmL/R `0.6/0.5 breakable`, LegL/R `0.7/0.8 breakable`, Weapon placeholder.
- Dwarf deriva de humanoid e adiciona Weapon `1.2`.
- `rebuildFromSprite` varre pixels do sprite ASCII, cacheia `cachedRelBoxes` por frame/facing, escala uniforme, fallback para schema estático se pixel ausente. Hitbox = pixels (pode ser mais estreita que AABB, por design).
- Fluxo: broadphase AABB do corpo → narrowphase por parte → melhor `damageMult/postureMult` vence → sem schema `1x` compatível, com schema e sem toque = whiff.
- Debug magenta/ciano/laranja (F2) + mira + números no original.

Exemplo de referência executável: `docs/MELEE_PER_PART_PLAN.md` no original (patch + 7 testes: head 2x, torso 1x, arm 0.6x, whiff, sem-schema, dedup, partícula + regressão AABB). No template, o resumo está em `docs/game-design/combat.md` e `melee-per-part.md`.

Para seu jogo: **comece com AABB puro**. Migre para per-part quando o soco já funciona e você quer "cabeça vale mais". O refactor paga custo; sem melee funcionando antes, é custo sem benefício.

## Como adaptar no seu jogo

1. `Melee` AABB + dedup por swing + `Contact 10` + `Death` (some + drop simples).
2. `Throw` dinamite + `Explosion` com raio fixo (sem per-part ainda).
3. `Body per-part` só depois, seguindo o plano de 7 testes acima.
4. `Telegraph` (aviso antes do golpe do inimigo) quando tiver elite — sem ele, dwarf parece injusto.
5. O que ignorar no começo: `BodySystem` completo, `WeaponRegistry`, `postureMult`, `breakable`, `PatienceSystem`.

## Erros comuns

- Sem dedup por swing (boss derrete em 1 frame).
- Hitbox válida fora da fase `Active` (soco pega atrás e em cima).
- Morte antes do dano no scheduler (kill perdida).
- Per-part sem broadphase AABB (lento) ou sem fallback sem-schema (inimigo novo invencível).
- Explosão sem `breakTilesInCircle` limitado (abre cratera até o bedrock).
