# Principles - Arquitetura

## Separação Core / Support
- `core/` contém enums, config, primitives, System base.
- `support/` contém lógica de jogo.
- `core` nunca inclui `support`. Garantido por `test-layers`.

## Sistema Scheduler
- `core::SystemScheduler` ordena por `priority()`.
- Bandas:
  0-99 input/time
  100-199 IA
  200-299 física
  300-399 combate
  400+ progressão/spawn
  900+ cleanup

## GameContext
- View não proprietária passada a sistemas.
- Dono permanece em `Game`.

## Auto-registro
- `BodySchemaRegistry`, `BehaviorRegistry`, `SkillRegistry`
- Construtores estáticos evitam lista de boot.

## Pool e Cooldown
- `core::Pool<T>` para partículas, throwables.
- `core::Cooldown` para i-frames, skills, knockback lock.
- Evita alocação por frame.
