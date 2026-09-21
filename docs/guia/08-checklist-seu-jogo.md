# 08 — Checklist: do clone ao seu jogo

Use esta lista para saber se já tem o mínimo e o que fazer depois. Marque `[x]` conforme avança.

## P0 — Janela e loop (guia 02)

- [ ] `make run` abre janela (800x800 ou 800x600) e fecha sem crash.
- [ ] Loop em fixed-step (`Time` com `1/30` ou `1/60`), lógica em `tick()`, render livre.
- [ ] `InputMap::beginFrame()` por frame (não por tick). `Left/Right/Jump` funcionam.
- [ ] `sprites::build()` (se houver) uma vez no `run()`, nunca em teste.
- [ ] `arial.ttf` carregado de `./arial.ttf` (copiado para `build/`).

## P0 — Mundo pisável (guia 03)

- [ ] `kBlockSize` congelado (ex.: 50). `kWorldSeed` fixo (ex.: 1337).
- [ ] `World::tileAt/isSolid/query/breakTile` funcionam (pode ser mapa fixo no início).
- [ ] `findSpawnTileX` encontra chão plano; player não nasce dentro da pedra.
- [ ] Flags `-ffp-contract=off -fno-fast-math` no Makefile (se usar noise/geração).
- [ ] (Depois) `Chunk 16x16 + ChunkManager radius=2` + `SpatialHash` + `Generation` pura.

## P0 — Player e câmera (guia 04)

- [ ] `Entity` com `w/h` + `tick()` + `collide()` por lado (Top/Bottom/Left/Right).
- [ ] Gravidade + terminal < tile (sem tunneling). Pulo com `onGround` correto.
- [ ] Água/lava como trigger (atravessa), não parede.
- [ ] `Camera.follow` com deadzone + lerp. Sem tremor.
- [ ] HUD mínimo: `HP`. `RunManager` com `paused/dead/restart`.

## P1 — 1 inimigo (guia 05)

- [ ] `Enemy { Entity + hp + ai }` + `EnemySystem forEach/removeDead/despawnFar`.
- [ ] Slime patrol + chase + hop. `ContactDamage 10`.
- [ ] `SpawnSystem` com anel `600–1000px` + teto + timer. `Factory` retorna `nullptr` em kind desconhecido.
- [ ] Debug F5 (overlay IA) ligado.

## P1 — Combate completo (guia 06)

- [ ] `Melee` AABB + fase `Active` + dedup por swing (`lastHitSwing`).
- [ ] `Death` apaga + dispara drop/partícula. Prioridades `Melee < Contact < Death`.
- [ ] `Throw` dinamite + `Explosion` com raio (sem per-part ainda).
- [ ] Debug F2 (hitboxes) ligado.
- [ ] (Depois) `Body per-part` (head 2x, torso 1x, arm 0.6x) + 7 testes do plano melee + `WeaponRegistry` + telegraph.

## P1 — Recompensa e assets (guia 07)

- [ ] Morte → 1 orb → coleta encostando (`DropSystem` simples).
- [ ] 1 sprite idle (ASCII ou PNG) no lugar do retângulo. `setSmooth(false)`.
- [ ] 5 testes: `loop, collision, slime_patrol, melee, chunks`. `make test` verde. `make test-layers` verde se tocou `core/`.

## P2 — Só depois do P0+P1 verdes

- [ ] Dwarf/elite + `SkillSystem/UtilityAI` + `PatienceSystem`.
- [ ] `StratumManager` (11 estratos) + checkpoint profundo.
- [ ] Biomas/cavernas/ores/lava + `BlockRegistry` completo + `noise_view`.
- [ ] Equipamentos (1 ASCII × N materiais) + animação (`WalkA/B/Jump...`) + `ScreenshotSystem`.
- [ ] Stress tests + `test-all` diário + `CONTRIBUTING` com donos por área.

## Sinal de que está pronto para expandir

`make run` abre, player anda/pula/morre/volta, slime patrulha/persegue/morre/dropa, `make test` verde. A partir daí cada item P2 é 1 branch + playtest de 15 min + `git revert` fácil se quebrar o feel.
