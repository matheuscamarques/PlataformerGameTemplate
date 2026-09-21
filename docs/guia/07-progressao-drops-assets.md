# 07 — Progressão, drops, assets, build e testes

## RunManager (o gate do tick)

`src/support/Progression/RunManager.*`: controla `dead / paused / restart`. No `App::tick()`, `frozen = run.isPaused() || run.isDead()` — se frozen, mundo e scheduler pulam, mas `run_.tick()` sempre roda para tratar restart (checkpoint mais fundo + respawn + 2 slimes no original).

No seu jogo: implemente `paused/dead/restart` antes de qualquer progressão. Morte sem respawn trava playtest; pause sem gate congela HUD junto.

## Drops e partículas (recompensa visível)

- `DropSystem` (prio `400`, pool `128`): orbs com `magnet 64px / collect 12px / speed 280 / grav 500 / ttl 12s`. `DeathSystem` dispara drops + partículas.
- `ParticleSystem` (prio `350`, `debris 512 + dust 4096`): só retângulos no original. Hit spark no melee, poeira no pulo, fumaça no dwarf.
- `ThrowSystem` (prio `220`, pool `64`) já coberto no guia 06.

Comece com: inimigo morre → 1 orb voa → encosta coleta. Magnet + TTL depois.

## Estratos e paciência (deixe para depois)

- `StratumManager` (prio `60`, roda cedo): 11 estratos, unlock, checkpoint mais fundo, ponto de respawn, `stratumBg` por profundidade.
- `PatienceSystem`: mecânica de fuse/paciência (ex.: dwarf cava/espera antes de explodir).
- Loop completo do original: `Spawn → Exploração → Combate → Drop → Progressão de estrato → Respawn` (`docs/game-design/progression.md`).
- No seu jogo: fundo de cor fixa + respawn no spawn inicial bastam. Estratos quando quiser progressão vertical real.

## Assets: sprite sem PNG (ASCII → Texture)

Pipeline (`core/sprite_from_ascii.h` + `assets/Sprites/*`):

1. `PaletteEntry { char ch; sf::Color color; BodyPartId part }` — cada caractere vira cor + parte do corpo.
2. `makeSprite(rows, w, h, pal)` cria `sf::Texture` via `sf::Image`, `setSmooth(false)` (pixel art nítida).
3. `PlayerSprites.h` (player `12x20`), `EnemySprites.h` (slime `14x12`, dwarf `14x18`), `EquipSprites.h` (1 ASCII × N materiais: Iron/Leather/Gold/Diamond — forma compartilhada, cor por material).
4. `SpriteSet.h` agrega (`playerPunch/helm/chest/legs/boots/gloves/swordIdle/Windup/Swing/axeIdle/...`), `SpriteFrameRegistry` resolve `frameData(id)`, `PlayerSprite.h` resolve `textureForFrame/equipSpritePos`.
5. `Body::rebuildFromSprite` deriva hitboxes dos pixels (guia 06).

Regras: `build()` uma vez no `run()` (precisa de GL), nunca em teste. Tokens em `docs/design-system/tokens.md`, `palette.md`, `sprites-ascii.md` (dims + convenções `Idle/WalkA/B/Jump...`).

Para seu jogo: comece com retângulos. Migre para 1 sprite idle quando colisão pronta. Equipamentos e frames de animação só quando idle anda.

## Build, testes e ferramentas (o que copiar do Makefile)

Original (`Makefile`, 95 linhas):

- `CXX=g++, -std=c++17 -Wall -Wextra -Isrc -MMD -MP -O2 -g -ffp-contract=off -fno-fast-math`, `LDLIBS=-lsfml-graphics -lsfml-window -lsfml-system`, `LDFLAGS=-Wl,-rpath-link,...`.
- `GAME_OBJS` = todos `src/**/*.cpp` menos `main.o`; cada `tests/test_*.cpp` linka contra eles (padrão auto-descoberto).
- Targets: `all/run/start/watch/test(fast)/test-all(+stress)/test-layers(core∌support)/noise-view/clean/clear`.
- `STRESS_TESTS = %_stress` fora do ciclo diário (lento por design, ex.: `slime_stress` ~1min).
- Template atual tem só `all/clean/run/test(echo)`. Falta: `GAME_OBJS`, `test-layers`, `test-all`, `-include *.d`, cópia de `arial.ttf`.

Testes (74 no original, `make test` roda 73 fast):

- Mundo/geração ~24 (biome/blocks/cave/chunks/grid/islands/lakes/lava/material/ores/peaks/sea/strata/surface/trenches/trees/wall/collision/contact/culling/layers).
- Player/combate ~16 (player/throw/sprite_sync/melee/parts/weapon/explosion/aim/cooldown/death/breaktile...).
- Inimigos/AI ~12 (slime chase/patrol/stress, dwarf, archetype, behavior_registry, factory, spawn, utility_ai, skill...).
- Infra ~14 (loop/time/inputmap/camera/spatialhash/eviction/lru/run_manager/drops/patience/debug_feed...).
- Assets ~8 (sprites/split/equipment/offset/flavor/palette/screenshot/particle).

Para seu jogo: 5 testes bastam no início — `loop`, `collision`, `slime_patrol`, `melee`, `chunks`. Padrão `tests/test_*.cpp`, sem GL.

Ferramenta: `tools/noise_view/noise_view.cpp` (`make noise-view` → `build/tools/noise_view`, usa só `Generation.cpp`, sem `Entity`, despeja em `build/noise/`). Copie como exemplo de tool standalone.

## Debug e trabalho em paralelo

- Debug no original (`support/Debug/`): `Overlay` (HUD/FPS), `Feed` (log de eventos F4), `BodyDump`, `ScreenshotSystem` (F12), char-view (F3), hitboxes (F2), IA (F5), mundo (F6), `AutoMelee` (F11), `AutoHurt` (F10). Ligue F1/F2/F5 desde o dia 1.
- Paralelo (`docs/PARALLEL_WORK.md` no original, `docs/principles/parallel-work.md` no template): tabela área→arquivos→dono→verificação, `make test` antes de cada push, `test-all` 1x/dia, avisar antes de mexer em header agregado (`SpriteSet.h`, `game.h`, `EnemyArchetype.h`).
- Docs gerados (`docs/doxygen/html+latex`, `Doxyfile.bak`, `uml/*.mdj`, `screenshots/`, `build/`, `compiled/`) — não versione. Leve só `Doxyfile` mínimo se quiser API.
