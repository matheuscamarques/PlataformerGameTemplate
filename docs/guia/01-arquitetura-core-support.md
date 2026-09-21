# 01 — Arquitetura: core / support / scheduler / GameContext

## A ideia em uma frase

`core` é estável e não conhece o jogo. `support` é o jogo e conhece `core`. `Game` é o dono de tudo. Sistemas conversam via `GameContext` (view, sem ownership) e rodam em ordem de prioridade no `SystemScheduler`.

## As pastas e o porquê

- **`src/core/`** — primitives, enums, config. Não pode incluir nada de `support/`. Verificado por `make test-layers` (`! grep -rn '#include.*support/' src/core/`).
  Contém: `Config.h` (`kBlockSize=50`, `kWorldSeed=1337`), `Time.*` (fixed-step), `System.h` (`System` + `SystemScheduler`), `Cooldown.h`, `Pool.h`, `Random.h`, `Noise.h`, `Math.h`, `Material.h`, `EntityKind.h` (`Player/Slime/Dwarf/TNT/Rock`), `BodyPart.h`, `sprite_from_ascii.h`, `Log.*`.

- **`src/support/`** — todos os sistemas do jogo. Cada um recebe `tick(dt, ctx)`. Subpastas no original: `Camera/`, `Combat/` (Melee/Contact/Explosion/Death/Body/Weapon), `Enemies/` (EnemySystem/Factory/Spawn/Behaviors/SlimeAI/DwarfAI), `Effects/` (Throw/Particle), `Input/` (InputMap), `Progression/` (RunManager/Drop/Stratum/Patience), `Skills/` (Skill/SkillSystem/UtilityAI), `Spatial/` (spatialhash), `Debug/` (Overlay/Feed/Screenshot/BodyDump), mais `GameContext.h`.

- **`src/entities/`** — `Entity` (AABB `x/y/w/h/vx/vy` + `tick()` que integra + `draw()` + `collide()`) e `Player/` (único jogável).

- **`src/world/`** — mundo voxel. `World` é a fachada (ninguém toca em `Chunk` direto). `ChunkManager` faz streaming. `Generation` são funções puras `(tx,ty,seed)`.

- **`src/game/`** — dono. `game.h` (holders), `App.cpp` (ciclo), `Bootstrapper.cpp` (`Game::main`), `Renderer.cpp` (todo draw), `Input.cpp` (poll).

- **`src/assets/`** — arte `ASCII -> Texture`. `SpriteSet.h` agrega tudo, `PlayerSprites.h` / `EnemySprites.h` / `EquipSprites.h` definem pixels, `SpriteFrameRegistry` resolve `frameData(id)`.

- **`src/component/` e `src/defines.h`** — legado. `Component : RectangleShape` é base de `Entity` no original. `defines.h` é só shim para `core/Config.h + EntityKind.h`. No seu jogo, pode ignorar `defines.h` e usar `core/` direto.

- **`src/window/`** — dono do `unique_ptr<RenderWindow>`. `Window(800,800)`, `setVerticalSyncEnabled(true)`.

## System + SystemScheduler (o coração)

Arquivo: `src/core/System.h` (no template já é funcional, 42 linhas).

```cpp
class System {
  virtual const char* name() const = 0;
  virtual int priority() const = 0;
  virtual void tick(float dt, GameContext& ctx) = 0;
  virtual bool enabled() const { return true; }
};
```

`SystemScheduler::add<T>(args...)` guarda `unique_ptr`, marca `dirty_`. No `tick`, se `dirty_`, faz `stable_sort` por `priority()` uma vez e depois chama cada sistema habilitado em ordem. `stable_sort` importa: mesma prioridade mantém ordem de inserção, determinístico.

Bandas de prioridade usadas no original (não invente números aleatórios):

- `0–99` input/time
- `100–199` IA (`EnemySystem 150`)
- `200–299` física (`Throw 220`, `Body 250`)
- `300–399` combate (`Melee 300`, `Contact 310`, `Explosion 320`, `Death 330`, `Particle 350`)
- `400+` progressão/spawn (`Drop 400`, `Spawn 410`, `Stratum 60` é exceção — roda cedo de propósito)

No seu jogo: input primeiro, física depois da IA, combate depois da física, spawn/drop por último, cleanup em `900+`.

## GameContext (como sistemas se falam sem dono compartilhado)

No template atual é `void*` (placeholder — não use assim). No original é struct de views sem ownership:

```cpp
struct GameContext {
  World* world; Player* player; InputMap* input;
  EnemySystem* enemies; ThrowSystem* throws; ExplosionSystem* explodes;
  DropSystem* drops; /* + targets, screenshots, debugFeed */
};
```

Regras:

1. Dono continua em `Game` (unique_ptr). `ctx` só aponta.
2. Sistema nunca deleta o que recebe.
3. Se `ctx.player` é nulo, retorne cedo (protege testes headless).
4. Monte `targets` (Player + slimes) uma vez por tick no `App`, não em cada sistema.

## Pool e Cooldown (por que existem)

- `core::Pool<T>` — array fixo reutilizável (ex.: `ThrowSystem pool 64`, `Drop orbs pool 128`, `Particle debris 512 + dust 4096`). Evita `new` por frame, evita GC/stutter, tamanho fixo = limite de design explícito.
- `core::Cooldown` — timer (`throwCooldown 0.5s`, `iframes 0.6s`). `tick(dt)`, `ready()`, `reset()`. Use para i-frames, cooldown de ataque, lock de knockback.

## Auto-registro (quando usar)

No original: `REGISTER_ENEMY_ARCHETYPE`, `REGISTER_BEHAVIOR`, `REGISTER_SKILL` via construtores estáticos. Evita editar fábrica para adicionar inimigo novo.

Para seu jogo mínimo: **não precisa**. Comece com `if (kind == "slime")` na Factory. Migre para macro só quando tiver 3+ inimigos e a lista de `if` incomodar.

## Regras para não quebrar

1. `core` nunca inclui `support`. Rode `make test-layers` se tocar em `core/`.
2. Prioridade explícita, sem dependência implícita entre sistemas.
3. Sem GL em teste: `sprites::build()` só no `run()`, nunca em `tests/`.
4. Sem lista global de entidades: itere via `World::forEachEntityInRect(view)` (culling embutido).
5. `InputMap::beginFrame()` por frame, nunca por tick (senão apaga edge quando há N ticks por frame).
