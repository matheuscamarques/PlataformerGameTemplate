# Game Design - Progressão

## Run Model
`RunManager` gate do tick. Controla morte, pause, restart.

## Estratos
`StratumManager` prioridade 60
- Unlock de strata
- Deepest checkpoint
- Respawn point

## Drops
`DropSystem` prioridade 400
- Orbs de XP com pool próprio
- `DeathSystem` dispara drops e partículas

## Patience
`PatienceSystem` para mecânicas de fuse/paciência de inimigos tipo dwarf

## Loop
Spawn → Exploração → Combate → Drop → Progressão de estrato → Respawn
