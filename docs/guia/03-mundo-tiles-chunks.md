# 03 — Mundo: tiles, chunks, geração e consultas

## A ideia em uma frase

`World` é a fachada que todo mundo usa. `ChunkManager` carrega/descarrega pedaços do mundo. `Generation` decide o que há em cada tile de forma pura e determinística. Ninguém fora de `world/` toca em `Chunk` direto.

## Tiles (o vocabulário do chão)

No original `src/world/Tile.h` tem 116 IDs (contrato de save — não renumere). Para seu jogo bastam 7:

`Air, Grass, Dirt, Stone, Water, Lava, Bedrock (+ COUNT)`

Convenções do original que valem copiar:

- `Tile` = estado sólido/quebrável. `BlockRegistry` mapeia `BlockId → propriedades` (aparência/material). `Material` define só cor.
- `isSolid(tile)`: `Water/Lava/Tree/Slime` **atravessam** (dano fica fora da colisão). Todo o resto sólido resolve Top/Bottom/Left/Right.
- `breakTile` com raio em tiles (para explosões). `Explosion::breakTilesInCircle(r=3 tiles)` no original.

## Chunk e ChunkManager (mundo infinito sem comer RAM)

- `Chunk.h`: `16x16` tiles, `tiles: vector<Tile>`, `entities: unique_ptr`, `SpatialHash HASH_CELL = 2 tiles`.
- `ChunkKey.h`: chave do chunk (cx, cy).
- `ChunkManager.h/.cpp`: streaming `radius=2` = 25 chunks ao redor do player, `maxLoaded=128`, evicção LRU **só de chunks `clean`**. Chunk `modified` (player quebrou algo) nunca é evictado, salvo `idle > 120s`. Isso garante: área intocada regenera idêntica; área mexida persiste.
- `World.h/.cpp`: fachada — `update(playerTile)`, `query(rect)`, `forEachEntityInRect`, `tileAt(tx,ty)`, `isSolid(tx,ty)`, `breakTile`.

Para seu jogo mínimo: pode começar com array 2D fixo + `World` façade com a mesma assinatura (`tileAt/isSolid/query`). Quando migrar para chunks, nenhum sistema muda — só `World.cpp` interno.

## Generation (funções puras, determinísticas)

`src/world/Generation.*`: funções puras `(tx, ty, seed) -> Tile`. Mesma entrada, mesma saída, sempre. Por isso chunk `clean` pode ser descartado e regenerado idêntico.

No original há: `surfaceHeight`, `RELIEF_FREQ 0.02 / AMP 9`, `mountain/peak/trench/cliff/cave/worm/mouth/lake/snowcap/ore/strataRock/biome (9: Ocean..Tundra)/trees/lava (SEA 26 / LAVA 6200 / BOTTOM 12000)/ocean/coastal`.

Para seu jogo: só `surfaceHeight(tx, seed)` + `tileType(tx, ty)` (se `ty < surface → Air`, se `== surface → Grass`, abaixo → `Dirt/Stone`, fundo → `Bedrock`) + `findSpawnTileX()` (varre x perto de 0 até achar chão plano). Adicione cavernas/ores/biomas depois.

Determinismo exige flags: `-ffp-contract=off -fno-fast-math` (sem elas `sin/cos/sqrt` fundem FMA e `noise_view/test_cave/test_ores` divergem 1 bit vs `-O0`).

## SpatialHash (broadphase barata)

`src/support/Spatial/spatialhash.*`: grade por chunk para `query(rect)` rápido. Fluxo: `World::query(player ± 1 tile)` → só entidades próximas → `player->collide(e)`. Sem isso, cada frame testaria player contra o mundo inteiro.

## Stratum (profundidade com significado)

`src/world/Stratum.h`: 11 estratos `0..10`, `stratumAt(ty)`, `checkpointTy`, `stratumBg`. No original `StratumManager` (prio 60) destrava estratos, guarda checkpoint mais fundo e ponto de respawn. No seu jogo pode ser só `cor de fundo por profundidade` no início; vire sistema quando quiser progressão vertical.

## Como adaptar no seu jogo

1. Defina `kBlockSize` (50 no original; 32 ou 16 também valem, mas congele cedo — tudo escala por ele).
2. Implemente `tileAt/isSolid/query/breakTile` primeiro com mapa fixo.
3. Implemente `findSpawnTileX` antes do Boot (sem ele o player nasce dentro da pedra).
4. Só então porte `ChunkManager` + `Generation` puros.
5. Use `tools/noise_view` (original: `make noise-view` → `build/tools/noise_view`, usa só `Generation.cpp`, sem `Entity`, despeja em `build/noise/`) para visualizar a geração sem abrir o jogo.
6. O que ignorar no começo: `BlockRegistry` completo, `Rocks/Rares/Strata*`, 9 biomas, lava/sea/ores, `StratumManager`, `PatienceSystem`.

## Erros comuns

- Renumerar `Tile` depois de salvar (quebra saves).
- `isSolid` tratando água/lava como parede (player trava) ou tratando pedra como atravessável (cai do mundo).
- Geração com `rand()` global em vez de função pura de `(tx,ty,seed)` (mundo muda a cada load).
- Esquecer `-fno-fast-math` e caçar bug fantasma de 1 pixel.
