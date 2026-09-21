# World Generation

## Estrutura
`World` façade, não expõe `Chunk` diretamente.
`ChunkManager` gerencia chunks ativos.
`Generation` usa `core::kWorldSeed`, `kBlockSize`.

## Blocos
`BlockRegistry` mapeia `BlockId` → propriedades.
`Material` define cor apenas.

## Tiles
`Tile` estado sólido / quebrável.
`breakTile` com raio de tiles para explosões.

## Convenções
- `findSpawnTileX` localiza spawn inicial
- Query por rect via `SpatialHash`
- Geração determinística com `-ffp-contract=off -fno-fast-math`
