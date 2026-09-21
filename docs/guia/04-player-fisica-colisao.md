# 04 — Player, física, colisão e câmera

## Entity (a base de tudo que se move)

`src/entities/Entity.hpp/.cpp : Component` no original:

- AABB `x/y/w/h`, velocidade `vx/vy`, `facing`.
- `tick()` integra posição (`x += vx*dt`, `y += vy*dt`).
- `draw()`, `isColide()`, `getBoundsTop/Bottom/Left/Right()` (fatias finas para resolver lado da colisão).
- `Component` é legado (`RectangleShape + FloatRect + name/x/y/w/h`). No seu jogo pode ser struct simples com AABB.

No template atual `Entity` é só `{x,y,vx,vy,facing}` — faltam `w/h`, vida e métodos. Adicione `w/h` primeiro; sem tamanho não há colisão.

## Física do player (números que funcionam)

Valores do original (`entities/Player/Player.*`, `Entity 30x50`, sprite `12x20 @2.5x`):

- Gravidade `+2px/tick²`, terminal `25px/tick`. Terminal < `kBlockSize (50px)` = sem tunneling (nunca atravessa 1 tile por passo).
- Horizontal `vx = ±9.8` (`+5` com `RunFast`).
- Pulo = teleporte `25px/tick` até `250px` (5 blocos), com `vy = 9.8` no pulo e `jumping` flag até o ápice.
- `hp 100`, `hurt(dmg)` com `iframes 0.6s`, `respawn()` com full-reset, `throwCooldown 0.5s`, `dynamite 999` (infinito no debug), combo `8/10/16 dmg`.
- `AimDir` em 8 direções + `swingAim` snapshot (mira congela no início do swing, não segue o mouse/tecla).
- `meleeHitbox()` só válida em fase `Active` (fora dela `width <= 0`).

Copie esses números como ponto de partida e ajuste 1 por vez com playtest. Mudar gravidade + velocidade juntas quebra o "feel" sem você saber qual causou.

## Colisão (lado certo, resposta certa)

`Player::collide(Entity/Component)` no original:

1. Broadphase: `World::query(player ± 1 tile)` via `SpatialHash` → poucas entidades.
2. Para cada sobreposição AABB: se `Water → swim`, se `Lava/Tree/Slime → atravessa` (dano é tratado em `ContactDamage`, não aqui).
3. Senão resolve por menor penetração: `Top/Bottom/Left/Right` + `jumping=false, vy=0` quando pousa.
4. `EnemySystem::physics` faz o mesmo para inimigos (gravidade + snap no chão).

Regras para seu jogo:

- Resolva **um eixo por vez** (X depois Y) ou pelo menor eixo. Resolver os dois juntos gruda na quina.
- Pouse (`onGround`) só quando colide por baixo com `vy >= 0`. Sem isso, pulo duplo infinito ou pulo que não sai.
- Água/lava como trigger, não parede. Parede invisível na água é o bug nº 1 de iniciantes.

## Câmera (seguir sem enjoar)

`src/support/Camera/Camera.*`:

- `follow(x, y)` com **deadzone** (zona morta central onde a câmera não mexe) + **lerp** (interpolação suave).
- `position()` = canto superior-esquerdo do mundo (não o centro).
- `viewRect / screenToWorld / worldToScreen` para culling e debug.

Sem deadzone: câmera treme a cada pixel. Sem lerp: salta. Sem clamp no mundo: mostra o vazio fora do mapa.

## Render do player (quando trocar retângulo por sprite)

Comece com retângulo. Quando colisão estiver certa, migre para sprite ASCII (guia 07). No original: `resolvePlayerSprite / textureForFrame / equipSpritePos`, `frameData(id)->rows/w/h/pal`, `SpriteSet::build()` uma vez.

## Como adaptar no seu jogo

1. `Entity` com `w/h` + `tick()` + `collide()` por lado.
2. Constantes de física copiadas, gravidade primeiro, pulo depois, horizontal por último.
3. `World::query` + `collide` antes de qualquer inimigo.
4. `Camera.follow(player)` + HUD de `HP` (texto basta).
5. `RunManager` gate (`dead/paused/restart` com checkpoint mais fundo + 2 slimes) desde cedo — morte sem respawn trava playtest.
6. O que ignorar no começo: `Body per-part`, `WeaponRegistry` (sword 16x8 / axe 8x20), `AimDir` 8 vias, equipamentos, `AutoMelee/AutoHurt` debug.

## Erros comuns

- Terminal velocity maior que o tile (tunneling através do chão fino).
- `onGround` nunca resetado (voo) ou resetado todo frame (pulo falha).
- `pressed(Jump)` lido por tick em vez de consumido por frame (pulo some quando há 2 ticks/frame).
- Câmera centrada no player sem offset (metade da tela mostra para onde você veio, não para onde vai — some `facing` lookahead depois).
