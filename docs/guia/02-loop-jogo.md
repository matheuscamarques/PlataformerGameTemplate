# 02 — Loop do jogo: main, Boot, tick fixo, input, render

## O caminho do `main()` até o primeiro frame

No original (`src/main.cpp` → `game/Bootstrapper.cpp` → `game/App.cpp`):

1. `main()` chama `Game::main()` dentro de `try/catch` com `LOG_ERROR`.
2. `Game::main()` (Boot): cria `Game + World(seed) + Player`, acha spawn (`findSpawnTileX`), posiciona player (`spawnTx * 50`), carrega `arial.ttf` (throw se faltar), registra sistemas no `scheduler_` e faz fiação (`throws->setExplosion(...)`), spawna 2 slimes (`spawn("slime", spawnTx ± 6)`).
3. `Game::run()` (App): chama `sprites::build()` **uma vez** (precisa de GL), entra no `while (running && window->isOpen())`.

No template atual `Game::run()` dá só 1 tick de `1/60`. Falta o `while`, a janela e o `Time`.

## Fixed-step (por que 30 TPS e não delta livre)

`src/core/Time.*` com `Time::setFixedStep(1/30)`:

```
while (janela aberta) {
  pollEvents();              // InputMap::beginFrame() + SFML poll
  Time::beginFrame();        // acumula tempo real
  ticks = consumeTicks();    // quantos passos fixos cabem
  for (cada tick) tick();    // lógica com dt fixo
  render(); display();
}
```

Por que fixo: física (`gravidade +2px/tick²`), IA e geração ficam determinísticos. Com delta variável, pulo e colisão mudam com FPS. Regra: **lógica em tick fixo, render livre**.

Detalhe crítico do original (`game/Input.cpp`): `beginFrame()` é por **frame**, nunca por tick. Se chamar por tick, o segundo tick do mesmo frame apaga o `pressed` do primeiro. Padrão: `pollEvents()` uma vez, depois N `tick()` consumindo via `held()`/`consume()`.

## O que o `tick()` faz (ordem de `App.cpp:77`)

1. Lê `input.held(Left/Right/Up/Down/RunFast)` → `player->move*/facing`.
2. Calcula `frozen = run.isPaused() || run.isDead()`. Se frozen, pula mundo e scheduler (mas `run_.tick()` sempre roda para tratar restart).
3. Se não frozen: `player->tick()`, `pressed(Light) → tryThrow()`, `pressed(CycleMaterial) → cicla Material`, `World::update(playerTile)`, `World::query(player ± 1 tile) → player->collide(e)`.
4. Monta `targets` (Player + slimes) e `GameContext{world, player, input, enemies, ...}`.
5. Resolve `currentFrameId` (player/inimigos) para sprite.
6. `debugFeed.tick()`; `scheduler_.tick()` só se `!frozen`.

## Input (held vs pressed)

`src/support/Input/InputMap.*`: dois arrays `curr[]/prev[]`, métodos `held()`, `pressed()` (borda de subida), `released()`, `bind()/addBind()`, `axisX/Y()`, `pollingMode` para headless.

Ações no original: `Left/Right/Up/Down/Jump/Roll/RunFast/Light(J-throw)/Heavy(K-melee)/Pause/Restart/CycleMaterial(M)/ToggleDebug(F1)/Hitboxes(F2)/CharView(F3)/Events(F4)/AI(F5)/World(F6)/AutoMelee(F11)/AutoHurt(F10)/Screenshot(F12)`.

Para seu jogo mínimo bastam: `Left/Right/Jump/Light/Heavy/Pause`. Adicione debug (F1/F2) desde o dia 1 — economiza horas.

## Renderer (o que desenhar e em que ordem)

`src/game/Renderer.cpp` (~577 linhas no original). Versão slim para seu jogo:

1. `clear(135,206,235)` (céu).
2. `camera.follow(player)` + `view.move(camPos)`.
3. Fundo chapado por estrato (`stratumBg(stratumAt(pty))` — no mínimo, cor fixa).
4. `forEachEntityInRect(view + 60px)` → `draw()` (culling: não itere lista global).
5. Sprites: player + equipamento + arma + inimigos + barks + overlay IA (F5) + throwables + partículas + hitbox melee amarela + drops + hitboxes debug (F2) + números.
6. HUD em `defaultView`: `HP/TNT/Mat/Estrato`, `VOCE MORREU / PAUSADO`.
7. `maybeCaptureMelee()` antes de `display()` (para screenshot de teste).

Regras de sprite: `setSmooth(false)` (pixel art), `build()` uma vez no `run()`, nunca em teste.

## Câmera (resumo — detalhe no guia 04)

`src/support/Camera/Camera.*`: `follow(x,y)` com deadzone + lerp, `position()` = canto superior-esquerdo do mundo, helpers `viewRect/screenToWorld/worldToScreen`. Sem deadzone a câmera enjoa; sem lerp ela treme.

## Como adaptar no seu jogo

- Copie `Time.*`, `InputMap.*`, `Camera.*`, `window/*` quase sem mudar.
- `Bootstrapper`: troque seed, spawn e lista de sistemas (comece com 3: `Enemy + Body + Melee`).
- `Renderer`: comece desenhando retângulos coloridos. Troque por sprites ASCII só quando colisão estiver certa.
- `App::tick()`: mantenha o `frozen` gate desde o início (pause/morte são mais fáceis agora que depois).
- Erros comuns: `beginFrame` no lugar errado (perde pulo), lógica com delta variável (pulo inconsistente), `sprites::build()` em teste (crash headless), iterar lista global em vez de `forEachEntityInRect` (lento + sem culling).
