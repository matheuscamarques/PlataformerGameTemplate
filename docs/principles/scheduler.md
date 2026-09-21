# Principles - Scheduler

## Ordem Determinística
`SystemScheduler::tick` faz `stable_sort` por priority apenas quando `dirty_`.

## Convenções
- Sistemas devem declarar `name()` e `priority()`.
- `enabled()` default true.
- Não criar dependências implícitas, usar prioridade explícita.

## Exemplo ordem
StratumManager 60 → EnemySystem 150 → BodySystem 250 → ThrowSystem 220 → MeleeSystem 300 → ExplosionSystem 320 → DeathSystem 330
