# 00 — Como começar: o mínimo para seu jogo de plataforma

Este guia explica o que qualquer pessoa que der `clone` no template precisa saber para começar seu próprio platformer, sem precisar ler o código inteiro do `plataformgame` original.

Nada aqui reimplementa código. É só explicação + onde olhar no original + o que adaptar.

## O que é "o mínimo"?

Um platformer jogável precisa de 7 coisas. Sem uma delas, não é jogo:

1. **Janela + loop** — abrir `sf::RenderWindow`, rodar em fixed-step, fechar sem crash.
2. **Input** — saber se tecla está segurada (`held`) ou foi apertada agora (`pressed`).
3. **Física + colisão** — gravidade, pulo, AABB contra tiles.
4. **Mundo** — chão e plataformas para pisar. No original: chunks infinitos. No seu jogo pode começar com tilemap fixo.
5. **Player** — entidade com posição, velocidade, vida.
6. **Câmera + render** — seguir o player, desenhar só o que está na tela.
7. **Boot** — um lugar que cria tudo e amarra os sistemas (o `Bootstrapper`).

Só depois disso faz sentido falar de inimigos, combate, drops e progressão (guias 05–07).

## Como clonar e rodar (referência do original)

No `plataformgame` original o fluxo é:

```bash
# dependências: g++ C++17, SFML 2.5 (graphics/window/system), make
make run    # compila src/**/*.cpp e abre build/plataformer (800x800)
make test   # roda ~73 testes rápidos (exclui *_stress)
make test-all       # inclui stress (~1 min)
make test-layers    # garante que src/core/ nunca inclui support/
```

Detalhes que quebram iniciantes (aprenda com o original):

- Flags de determinismo: `-ffp-contract=off -fno-fast-math`. Sem elas, a geração procedural diverge 1 bit entre `-O0` e `-O2`.
- Fonte: `arial.ttf` é copiado para `build/` no link. `font.loadFromFile("./arial.ttf")` falha se você rodar de outra pasta.
- Link SFML no Linux com `ld` do brew: precisa de `-Wl,-rpath-link,/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu`.
- `ccache` é opcional, só acelera rebuild em 30–50%.
- Testes nunca chamam `sprites::build()` (precisa de contexto GL). Só o `run()` chama, uma vez.

## Estrutura de pastas (o que cada uma significa)

```
src/core/      Fundamento. Sem SFML pesado, sem support/. Config, Time, System, Pool, Random, Noise, Math.
src/support/   Lógica do jogo. Tudo recebe GameContext e implementa tick(dt, ctx).
src/entities/  Entity base (AABB + velocidade) + Player jogável.
src/world/     Mundo voxel infinito. Tile, Chunk, ChunkManager, Generation, World façade.
src/game/      Dono. game.h, App (loop), Bootstrapper (montagem), Renderer (draw), Input (poll).
src/assets/    Arte ASCII -> Texture. Sprites do player, inimigos, equipamentos.
src/component/ Legado. Component : RectangleShape herdado. Entity deriva dele no original.
src/window/    Dono da sf::RenderWindow.
tests/         test_*.cpp auto-descobertos pelo Makefile. Sem GL.
tools/         noise_view: visualizador standalone da geração (sem Entity).
```

No template atual `src/world/` e `src/assets/` estão vazios e `src/game/` é esqueleto de 1 tick. Os guias 01–07 explicam o que cada pasta deveria conter, na ordem em que você deve implementar.

## Ordem recomendada para seu jogo

1. Leia `01-arquitetura-core-support.md` — entenda as regras antes de codar.
2. Leia `02-loop-jogo.md` — faça a janela abrir e fechar.
3. Leia `03-mundo-tiles-chunks.md` — faça um chão pisável (comece fixo, evolua para chunks).
4. Leia `04-player-fisica-colisao.md` — faça o boneco andar e pular.
5. Só então: `05-inimigos-ia.md`, `06-combate-dano-morte.md`, `07-progressao-drops-assets.md`.
6. Use o checklist em `08-checklist-seu-jogo.md` para saber quando está "pronto para expandir".

## Onde olhar no original (mapa rápido)

| Quero entender... | Olhe em `plataformgame/src/...` |
|---|---|
| Loop, tick, prioridades | `game/App.cpp`, `game/Bootstrapper.cpp`, `main.cpp` |
| Input sem perder edge | `game/Input.cpp`, `support/Input/InputMap.*` |
| Física sem tunneling | `entities/Player/Player.cpp`, `entities/Entity.cpp` |
| Mundo infinito determinístico | `world/World.*`, `world/ChunkManager.*`, `world/Generation.*` |
| Câmera que não enjoa | `support/Camera/Camera.*` |
| Render com culling | `game/Renderer.cpp` (~577 linhas) |
| 1 inimigo simples | `support/Enemies/SlimeAI.*`, `Behaviors.cpp` |
| Soco que acerta | `support/Combat/MeleeSystem.*` |
| Morrer e voltar | `support/Progression/RunManager.*` |
| Sprite sem PNG | `assets/Sprites/PlayerSprites.h`, `core/sprite_from_ascii.h` |
| Build e testes | `Makefile`, `tests/test_*.cpp`, `tools/noise_view/` |

> Dica: não copie tudo. Copie o mínimo de cada arquivo listado nos guias e adapte constantes (gravidade, velocidade, tamanho do tile) ao seu jogo.
