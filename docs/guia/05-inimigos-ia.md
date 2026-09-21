# 05 — Inimigos e IA: do slime parado ao dwarf que recua

## EnemySystem (o gerente)

`src/support/Enemies/EnemySystem.*`, prioridade `150` (roda na banda de IA, antes da física):

- Guarda `vector<Enemy>` onde `Enemy { Entity body, Behavior* ai, EnemyResources resources, Body bodyParts }`.
- Métodos: `forEach(fn)`, `removeDead()`, `despawnFar(player, 1600px)`, física própria (gravidade + snap no chão, igual ao player mas mais simples).
- Nunca crasha em kind desconhecido: `Factory::spawnEnemy(kind)` retorna `nullptr` se não registrado.

`SpawnSystem.h/.cpp` (prio `410`, por último): orçamento por estrato, timer `0.5s`, anel `600–1000px` do player (não spawna em cima, não spawna longe demais), despawn além de `1600px`, teto `100` inimigos. Sem teto e sem anel, o jogo spawna 1000 slimes ou nenhum.

## Os 2 inimigos do original (copie 1, estude o outro depois)

**Slime (trash, comece por ele)** — `hp 30`, `40x30`:

- `SlimeAI`: patrol vai-e-volta + vira na parede, chase se `|dx|,|dy| < 400` + hop (pulinho), skill `slime_spit` (projétil).
- Por que é o ideal para template: 2 estados, sem telegraph, sem recuo, sem equipamento.

**Dwarf (elite, deixe para depois)** — `hp 60`, `36x44`:

- `DwarfAI`: `Patrol / Alert / ThrowWindup / Release / Recover / Melee / Retreat`, aggro radial `200px`, skills equipadas `dwarf_dynamite + dwarf_melee` + registradas `smoke/barrel/dig/collapse`.
- Traz `SkillSystem + UtilityAI + PatienceSystem` junto. Não porte sem eles.

## Behavior e Factory (como adicionar inimigo sem editar fábrica)

No original:

- `Behavior.h` (interface `onTakeHit/update`), `BehaviorRegistry.h` + macro `SUPPORT_REGISTER_BEHAVIOR` (auto-registro via construtor estático), `Behaviors.cpp` (liga kinds a IAs), `VariantRegistry.h`, `EnemyArchetype.h` (spawn + recursos + schema de corpo), `EnemyResources.*` (hp/postura/morte), `Barks.h` (falas).
- Extensão = `REGISTER_ENEMY_ARCHETYPE + REGISTER_BEHAVIOR + SUPPORT_REGISTER_BEHAVIOR`. `Factory::spawnEnemy(kind)` resolve sem `if` encadeado.

Para seu jogo mínimo: **comece com `if`**:

```cpp
if (kind == "slime") return makeSlime(x, y);
// dwarf depois
return nullptr; // kind desconhecido nunca crasha
```

Migre para macro quando tiver 3+ tipos e o `if` incomodar. O padrão de macro está documentado em `docs/game-design/enemies-skills.md` e `docs/principles/architecture.md` (auto-registro).

## Skills e UtilityAI (quando precisa)

- `Skill.h` (`SkillDef` com custo, cooldown, telegraph, `execute`), `SkillSystem.*` (cooldowns por inimigo), `UtilityAI.cpp` (scoring determinístico: cada skill dá uma nota, maior nota vence).
- Slime usa 1 skill direta. Dwarf usa scoring entre 6 skills.
- Regra: 1–2 skills → `if` + `Cooldown`. 3+ com escolha tática → `UtilityAI`.

## Como adaptar no seu jogo

1. `Enemy { Entity + hp + ai* }` + `EnemySystem` com `forEach/removeDead/despawnFar` + física com gravidade.
2. `SlimeAI` patrol/chase/hop + `ContactDamage 10` (guia 06) antes de qualquer projétil.
3. `SpawnSystem` com anel + teto + timer desde o dia 1 (sem ele, playtest ou vazio ou caos).
4. `Factory` com `if` + `nullptr` para desconhecido.
5. Debug: overlay IA (F5 no original) + `Barks` (texto sobre a cabeça) economizam horas ("por que ele não me persegue?").
6. O que ignorar no começo: `DwarfAI`, `UtilityAI`, `SkillSystem`, `VariantRegistry`, `Barks`, `PatienceSystem`, `StratumManager`.

## Erros comuns

- IA sem `despawnFar` (mundo enche, FPS cai, save cresce).
- Spawn sem anel mínimo (inimigo nasce em cima do player = morte injusta).
- `Factory` com `throw` ou `assert` em kind desconhecido (um typo crasha o jogo; retorne `nullptr`).
- Chase sem limite vertical (`|dy|` ignorado → slime tenta alcançar player 10 telas acima e trava na parede).
- Física de inimigo sem snap (vibra sobre o chão) ou sem gravidade (flutua).
