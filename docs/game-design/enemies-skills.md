# Enemies e Skills

## EnemySystem prioridade 150
- `Enemy { Entity body, Behavior* ai, EnemyResources, Body bodyParts }`
- `forEach`, `removeDead`, `despawnFar`

## Behavior Registry
Auto-registro via macro `SUPPORT_REGISTER_BEHAVIOR`
- `SlimeAI`, `DwarfAI`
- Sem edição de fábrica

## Skill Registry
`SkillDef` com custo, cooldown, telegraph, `execute`
Auto-registro via `REGISTER_SKILL`
`SkillSystem` gerencia cooldowns por inimigo
`UtilityAI` scoring determinístico

## Arquétipos
`EnemyArchetype` define spawn, recursos, schema de corpo.
